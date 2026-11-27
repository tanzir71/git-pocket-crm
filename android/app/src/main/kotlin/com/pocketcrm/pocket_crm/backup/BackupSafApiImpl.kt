package com.pocketcrm.pocket_crm.backup

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

/**
 * Storage Access Framework (SAF) bridge for Backup and Export (Spec 12).
 * Streams files in 64 KB chunks between cache files and Android content URIs
 * so large backups never sit in memory and no storage permission is needed.
 */
class BackupSafApiImpl(
    private val activity: Activity,
) : BackupSafApi {
    companion object {
        const val REQ_CREATE_DOCUMENT = 4201
        const val REQ_PICK_DOCUMENT = 4202
        private const val BUFFER_SIZE = 64 * 1024
    }

    private var pendingCreate: CompletableDeferred<String?>? = null
    private var pendingPick: CompletableDeferred<Uri?>? = null

    @Suppress("DEPRECATION")
    override suspend fun createDocument(name: String, mime: String): String? {
        pendingCreate?.cancel()
        val deferred = CompletableDeferred<String?>()
        pendingCreate = deferred

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mime
            putExtra(Intent.EXTRA_TITLE, name)
        }
        activity.startActivityForResult(intent, REQ_CREATE_DOCUMENT)
        return deferred.await()
    }

    override suspend fun copyFileToUri(path: String, uri: String) {
        withContext(Dispatchers.IO) {
            val source = File(path)
            if (!source.exists()) {
                throw FlutterError("FILE_NOT_FOUND", "Backup source file not found: $path", null)
            }
            val parsedUri = Uri.parse(uri)
            val out = activity.contentResolver.openOutputStream(parsedUri, "wt")
                ?: activity.contentResolver.openOutputStream(parsedUri)
                ?: throw FlutterError("URI_OPEN_FAILED", "Could not open output stream for $uri", null)
            out.use { outputStream ->
                FileInputStream(source).use { inputStream ->
                    val buffer = ByteArray(BUFFER_SIZE)
                    while (true) {
                        val read = inputStream.read(buffer)
                        if (read <= 0) break
                        outputStream.write(buffer, 0, read)
                    }
                    outputStream.flush()
                }
            }
        }
    }

    @Suppress("DEPRECATION")
    override suspend fun pickDocument(mimeTypes: List<String>): String? {
        pendingPick?.cancel()
        val deferred = CompletableDeferred<Uri?>()
        pendingPick = deferred

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            if (mimeTypes.isNotEmpty() && !mimeTypes.contains("*/*")) {
                putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
            }
        }
        activity.startActivityForResult(intent, REQ_PICK_DOCUMENT)
        val uri = deferred.await() ?: return null

        return withContext(Dispatchers.IO) {
            val cacheDir = File(activity.cacheDir, "backup_pick")
            if (!cacheDir.exists()) cacheDir.mkdirs()
            val displayName = resolveDisplayName(uri) ?: "picked_backup.pcrm"
            val safeName = displayName.replace(Regex("[^\\w.\\-]"), "_")
            val dest = File(cacheDir, "${System.currentTimeMillis()}_$safeName")
            val input = activity.contentResolver.openInputStream(uri)
                ?: throw FlutterError("URI_READ_FAILED", "Could not read selected file", null)
            input.use { inputStream ->
                FileOutputStream(dest).use { outputStream ->
                    val buffer = ByteArray(BUFFER_SIZE)
                    while (true) {
                        val read = inputStream.read(buffer)
                        if (read <= 0) break
                        outputStream.write(buffer, 0, read)
                    }
                    outputStream.flush()
                }
            }
            dest.absolutePath
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return when (requestCode) {
            REQ_CREATE_DOCUMENT -> {
                val uri = if (resultCode == Activity.RESULT_OK) data?.data?.toString() else null
                pendingCreate?.complete(uri)
                pendingCreate = null
                true
            }
            REQ_PICK_DOCUMENT -> {
                val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
                pendingPick?.complete(uri)
                pendingPick = null
                true
            }
            else -> false
        }
    }

    fun dispose() {
        pendingCreate?.complete(null)
        pendingCreate = null
        pendingPick?.complete(null)
        pendingPick = null
    }

    private fun resolveDisplayName(uri: Uri): String? {
        return try {
            activity.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { c ->
                if (c.moveToFirst()) c.getString(0) else null
            }
        } catch (_: Throwable) {
            null
        }
    }
}
