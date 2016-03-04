package net.namekdev.theconsole.utils;

import static java.nio.file.StandardWatchEventKinds.*;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.FileVisitor;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.WatchEvent;
import java.nio.file.WatchEvent.Kind;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.TreeMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * The recursive file watcher monitors a folder (and its sub-folders).
 * The modified version collects all events to remove duplicates.
 *
 * <p>The class walks through the file tree and registers to a watch to every sub-folder.
 * For new folders, a new watch is registered, and stale watches are removed.
 *
 *
 * @author Philipp C. Heckel <philipp.heckel@gmail.com>
 * @author Namek
 */
public class RecursiveWatcher {
	private Path root;
	private int settleDelay;
	private WatchListener listener;

	private AtomicBoolean running;

	private WatchService watchService;
	private Thread watchThread;
	private Map<Path, WatchKey> pathToWatchKeyMap;
	private Map<WatchKey, Path> watchKeyToPathMap;

	private Queue<FileChangeEvent> eventQueue;
	private Map<String, FileChangeEvent> eventQueueByFilename;

	private Timer timer;

	public RecursiveWatcher(Path root, int settleDelay, WatchListener listener) {
		this.root = root;
		this.settleDelay = settleDelay;
		this.listener = listener;

		this.running = new AtomicBoolean(false);

		this.watchService = null;
		this.watchThread = null;
		this.pathToWatchKeyMap = new HashMap<Path, WatchKey>();
		this.watchKeyToPathMap = new HashMap<WatchKey, Path>();
		this.eventQueue = new LinkedList<FileChangeEvent>();
		this.eventQueueByFilename = new TreeMap<String, FileChangeEvent>();

		this.timer = null;
	}

	/**
	 * Starts the watcher service and registers watches in all of the sub-folders of
	 * the given root folder.
	 *
	 * <p><b>Important:</b> This method returns immediately, even though the watches
	 * might not be in place yet. For large file trees, it might take several seconds
	 * until all directories are being monitored. For normal cases (1-100 folders), this
	 * should not take longer than a few milliseconds.
	 */
	public void start() throws IOException {
		watchService = FileSystems.getDefault().newWatchService();

		watchThread = new Thread(new Runnable() {
			@Override
			public void run() {
				running.set(true);
				walkTreeAndSetWatches();

				while (running.get()) {
					try {
						WatchKey watchKey = watchService.take();
						Path folder = watchKeyToPathMap.get(watchKey);

						for (WatchEvent<?> event : watchKey.pollEvents()) {
							try {
								WatchEvent.Kind<?> kind = event.kind();

								if (kind == OVERFLOW) {
									continue;
								}

								WatchEvent<Path> evt = (WatchEvent<Path>) event;
								Path path = evt.context();
								Path fullPath = folder.resolve(path);
								System.out.println(evt.kind().toString() + ": " + fullPath.toString());

								FileChangeEvent prevEvt = eventQueueByFilename.get(fullPath.toString());

								if (prevEvt != null) {
									if (prevEvt.eventType == evt.kind()) {
										continue;
									}

									if (prevEvt.eventType == ENTRY_CREATE && evt.kind() == ENTRY_MODIFY) {
										continue;
									}
								}

								FileChangeEvent changeEvent = new FileChangeEvent(folder, evt);

								eventQueueByFilename.put(fullPath.toString(), changeEvent);
								eventQueue.add(changeEvent);
							}
							catch (Exception exc) {
								exc.printStackTrace();
							}
						}

						watchKey.reset();
						resetWaitSettlementTimer();
					}
					catch (Exception e) {
						running.set(false);
					}
				}
			}
		}, "Recursive Watcher");

		watchThread.start();
	}

	public synchronized void stop() {
		if (watchThread != null) {
			try {
				watchService.close();
				running.set(false);
				watchThread.interrupt();
			}
			catch (IOException e) { }
		}
	}

	private synchronized void resetWaitSettlementTimer() {
		if (timer != null) {
			timer.cancel();
			timer = null;
		}

		timer = new Timer("WatchTimer");
		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				walkTreeAndSetWatches();
				unregisterStaleWatches();

				fireObtainedEventQueue();
			}
		}, settleDelay);
	}

	private synchronized void walkTreeAndSetWatches() {
		try {
			Files.walkFileTree(root, new FileVisitor<Path>() {
				@Override
				public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
					registerWatch(dir);
					return FileVisitResult.CONTINUE;
				}

				@Override
				public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
					return FileVisitResult.CONTINUE;
				}

				@Override
				public FileVisitResult visitFileFailed(Path file, IOException exc) throws IOException {
					return FileVisitResult.CONTINUE;
				}

				@Override
				public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
					return FileVisitResult.CONTINUE;
				}
			});
		}
		catch (IOException e) { }
	}

	private synchronized void unregisterStaleWatches() {
		Set<Path> paths = new HashSet<Path>(pathToWatchKeyMap.keySet());
		Set<Path> stalePaths = new HashSet<Path>();

		for (Path path : paths) {
			if (!Files.exists(path, LinkOption.NOFOLLOW_LINKS)) {
				stalePaths.add(path);
			}
		}

		if (stalePaths.size() > 0) {
			for (Path stalePath : stalePaths) {
				unregisterWatch(stalePath);
			}
		}
	}

	private synchronized void registerWatch(Path dir) {
		if (!pathToWatchKeyMap.containsKey(dir)) {
			try {
				WatchKey watchKey = dir.register(watchService, ENTRY_CREATE, ENTRY_DELETE, ENTRY_MODIFY, OVERFLOW);
				pathToWatchKeyMap.put(dir, watchKey);
				watchKeyToPathMap.put(watchKey, dir);
			}
			catch (IOException e) { }
		}
	}

	private synchronized void unregisterWatch(Path dir) {
		WatchKey watchKey = pathToWatchKeyMap.get(dir);

		if (watchKey != null) {
			watchKey.cancel();
			pathToWatchKeyMap.remove(dir);
			watchKeyToPathMap.remove(watchKey);
		}
	}

	private synchronized void fireObtainedEventQueue() {
		listener.onWatchEvents(eventQueue);
		eventQueue.clear();
		eventQueueByFilename.clear();
	}

	public interface WatchListener {
		public void onWatchEvents(Queue<FileChangeEvent> events);
	}

	public static class FileChangeEvent {
		public final Path parentFolderPath;
		public final Path relativePath;
		public final Kind<Path> eventType;

		public FileChangeEvent(Path folderPath, WatchEvent<Path> event) {
			this.parentFolderPath = folderPath;
			this.relativePath = event.context();
			this.eventType = event.kind();
		}
	}
}
