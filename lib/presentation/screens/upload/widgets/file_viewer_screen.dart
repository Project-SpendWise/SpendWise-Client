import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:excel/excel.dart' hide Table;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:spendwise_client/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/file_model.dart';
import '../../../../providers/file_provider.dart';

class FileViewerScreen extends ConsumerStatefulWidget {
  final FileModel file;

  const FileViewerScreen({
    super.key,
    required this.file,
  });

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  Uint8List? _fileBytes;
  bool _isLoading = true;
  String? _error;
  String? _tempFilePath;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void dispose() {
    // Clean up temp file if created
    if (_tempFilePath != null) {
      try {
        final file = File(_tempFilePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    super.dispose();
  }

  Future<void> _loadFile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final fileNotifier = ref.read(fileListProvider.notifier);
      final fileBytes = await fileNotifier.downloadFile(widget.file.id);

      if (fileBytes != null && fileBytes.isNotEmpty) {
        debugPrint('File loaded: ${widget.file.originalFilename}, size: ${fileBytes.length} bytes, type: ${widget.file.fileType}');
        
        // For XLSX files, verify it's a valid ZIP structure
        if (widget.file.fileType.toLowerCase() == 'xlsx' || 
            widget.file.originalFilename.toLowerCase().endsWith('.xlsx')) {
          if (fileBytes.length >= 2) {
            final isZip = fileBytes[0] == 0x50 && fileBytes[1] == 0x4B; // PK signature
            debugPrint('XLSX file verification:');
            debugPrint('  ZIP signature: ${isZip ? "Valid" : "INVALID"}');
            debugPrint('  File size: ${fileBytes.length} bytes');
            
            if (!isZip) {
              debugPrint('WARNING: XLSX file does not have valid ZIP signature!');
              setState(() {
                _error = 'Invalid XLSX file: File does not appear to be a valid Excel file. The file may be corrupted.';
                _isLoading = false;
              });
              return;
            }
          }
        }
        
        setState(() {
          _fileBytes = Uint8List.fromList(fileBytes);
          _isLoading = false;
        });
      } else {
        debugPrint('File download returned null or empty: ${widget.file.id}');
        setState(() {
          _error = 'Failed to load file: No data received';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading file: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndOpenFile() async {
    if (_fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file data available. Please retry the download.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving file...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final tempDir = await getTemporaryDirectory();
      // Sanitize filename to avoid path issues
      final sanitizedFilename = widget.file.originalFilename
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final file = File('${tempDir.path}/$sanitizedFilename');
      
      // Write file bytes
      await file.writeAsBytes(_fileBytes!);
      _tempFilePath = file.path;

      debugPrint('File saved to: ${file.path}');
      debugPrint('File size: ${file.lengthSync()} bytes');

      // Open with external app
      final result = await OpenFilex.open(file.path);
      
      if (mounted) {
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}\nFile saved to: ${file.path}'),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File opened successfully'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving/opening file: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildPdfViewer() {
    if (_fileBytes == null) {
      return const Center(child: Text('No file data'));
    }

    // Save to temp file for PDF viewer
    return FutureBuilder<String>(
      future: _saveTempFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error loading PDF: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAndOpenFile,
                  child: const Text('Open with External App'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No file path available'));
        }
        try {
          final file = File(snapshot.data!);
          if (!file.existsSync()) {
            return const Center(child: Text('File not found'));
          }
          return SfPdfViewer.file(file);
        } catch (e) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error viewing PDF: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAndOpenFile,
                  child: const Text('Open with External App'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildExcelViewer() {
    if (_fileBytes == null) {
      return const Center(child: Text('No file data'));
    }

    try {
      if (_fileBytes!.isEmpty) {
        return const Center(child: Text('File is empty'));
      }

      // Verify file integrity before decoding
      debugPrint('Attempting to decode Excel file:');
      debugPrint('  File size: ${_fileBytes!.length} bytes');
      debugPrint('  File type: ${widget.file.fileType}');
      debugPrint('  Original filename: ${widget.file.originalFilename}');
      
      // Check if it's a ZIP file (XLSX format)
      if (_fileBytes!.length >= 2) {
        final isZip = _fileBytes![0] == 0x50 && _fileBytes![1] == 0x4B; // PK signature
        debugPrint('  ZIP signature detected: $isZip');
        
        if (isZip && _fileBytes!.length >= 4) {
          // Check for XLSX-specific structure
          debugPrint('  First 4 bytes: ${_fileBytes!.take(4).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
        }
      }
      
      // Try to decode the Excel file
      debugPrint('Decoding Excel file...');
      final excel = Excel.decodeBytes(_fileBytes!);
      final sheets = <String>[];

      // Get all sheet names
      for (var sheetName in excel.sheets.keys) {
        sheets.add(sheetName);
      }

      if (sheets.isEmpty) {
        return const Center(child: Text('No sheets found in Excel file'));
      }

      return DefaultTabController(
        length: sheets.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: sheets.map((name) => Tab(text: name)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: sheets.map((sheetName) {
                  final sheet = excel.sheets[sheetName];
                  if (sheet == null) {
                    return const Center(child: Text('Sheet not found'));
                  }
                  return _buildExcelTable(sheet);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      // Log the error for debugging
      debugPrint('Excel viewer error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('File details:');
      debugPrint('  Size: ${_fileBytes?.length ?? 0} bytes');
      debugPrint('  Type: ${widget.file.fileType}');
      debugPrint('  Filename: ${widget.file.originalFilename}');
      
      // Check file integrity
      bool fileIntegrityIssue = false;
      String integrityMessage = '';
      
      if (_fileBytes != null && _fileBytes!.isNotEmpty) {
        // Check ZIP signature for XLSX
        if (_fileBytes!.length >= 2) {
          final hasZipSignature = _fileBytes![0] == 0x50 && _fileBytes![1] == 0x4B;
          if (!hasZipSignature && (widget.file.fileType.toLowerCase() == 'xlsx' || 
              widget.file.originalFilename.toLowerCase().endsWith('.xlsx'))) {
            fileIntegrityIssue = true;
            integrityMessage = 'File does not have valid ZIP signature (XLSX files are ZIP archives)';
          }
        }
        
        // Check if file is too small (likely incomplete)
        if (_fileBytes!.length < 1000) {
          fileIntegrityIssue = true;
          integrityMessage = 'File is too small (${_fileBytes!.length} bytes) - likely incomplete';
        }
      }
      
      // Check if error message suggests file corruption
      final errorMessage = e.toString().toLowerCase();
      final isCorrupted = errorMessage.contains('corrupt') || 
                          errorMessage.contains('damaged') ||
                          errorMessage.contains('invalid') ||
                          errorMessage.contains('format') ||
                          errorMessage.contains('zip') ||
                          fileIntegrityIssue;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                isCorrupted 
                  ? 'Excel file appears to be corrupted or incomplete'
                  : 'Error reading Excel file: $e',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File size: ${_fileBytes?.length ?? 0} bytes',
              style: AppTextStyles.bodySmall,
            ),
            if (isCorrupted) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      fileIntegrityIssue && integrityMessage.isNotEmpty
                        ? integrityMessage
                        : 'This may be due to an incomplete download. Try downloading the file again.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (fileIntegrityIssue) ...[
                      const SizedBox(height: 8),
                      Text(
                        'The file may be corrupted on the server or the download was incomplete.',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadFile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Download'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _saveAndOpenFile,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Externally'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildExcelTable(Sheet sheet) {
    // Get all rows and columns from the sheet
    final rows = <List<Data?>>[];
    int maxCols = 0;

    // Iterate through all rows
    for (var row in sheet.rows) {
      final rowData = <Data?>[];
      for (var cell in row) {
        rowData.add(cell);
      }
      if (rowData.length > maxCols) {
        maxCols = rowData.length;
      }
      rows.add(rowData);
    }

    if (rows.isEmpty) {
      return const Center(child: Text('Empty sheet'));
    }

    // Get header row (first row) if available
    final headerRow = rows.isNotEmpty ? rows[0] : null;
    final hasHeader = headerRow != null && headerRow.isNotEmpty;
    final dataStartRow = hasHeader ? 1 : 0;
    final dataRowCount = rows.length - dataStartRow;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: List.generate(
            maxCols,
            (index) {
              String headerText = _getColumnName(index);
              if (hasHeader && index < headerRow!.length) {
                final headerCell = headerRow[index];
                if (headerCell != null) {
                  headerText = headerCell.value?.toString() ?? headerText;
                }
              }
              return DataColumn(
                label: Text(
                  headerText,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          rows: List.generate(
            dataRowCount > 100 ? 100 : dataRowCount, // Limit to 100 rows for performance
            (rowIndex) {
              final actualRowIndex = rowIndex + dataStartRow;
              if (actualRowIndex >= rows.length) {
                return DataRow(
                  cells: List.generate(
                    maxCols,
                    (colIndex) => const DataCell(Text('')),
                  ),
                );
              }
              final row = rows[actualRowIndex];
              return DataRow(
                cells: List.generate(
                  maxCols,
                  (colIndex) {
                    final cell = colIndex < row.length ? row[colIndex] : null;
                    final value = cell?.value?.toString() ?? '';
                    return DataCell(
                      Text(
                        value,
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getColumnName(int index) {
    String result = '';
    int num = index;
    while (num >= 0) {
      result = String.fromCharCode(65 + (num % 26)) + result;
      num = (num ~/ 26) - 1;
    }
    return result;
  }

  Widget _buildCsvViewer() {
    if (_fileBytes == null) {
      return const Center(child: Text('No file data'));
    }

    try {
      // Try UTF-8 first, fallback to latin1 if needed
      String content;
      try {
        content = utf8.decode(_fileBytes!);
      } catch (e) {
        // Fallback to latin1 if UTF-8 fails
        content = latin1.decode(_fileBytes!);
      }
      
      // Handle different line endings
      content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        return const Center(child: Text('Empty CSV file'));
      }

      // Parse header - handle quoted values
      final header = _parseCsvLine(lines[0]);
      
      // Parse rows (limit to 1000 for performance)
      final dataRows = lines.skip(1).take(1000).map((line) {
        return _parseCsvLine(line);
      }).toList();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: header.map((col) {
              return DataColumn(
                label: Text(
                  col,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            rows: dataRows.map((row) {
              return DataRow(
                cells: row.map((cell) {
                  return DataCell(
                    Text(
                      cell,
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error reading CSV file: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAndOpenFile,
              child: const Text('Open with External App'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildUnsupportedViewer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.file.originalFilename,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 8),
          Text(
            'File type: ${widget.file.fileType.toUpperCase()}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Size: ${widget.file.formattedSize}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveAndOpenFile,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open with External App'),
          ),
        ],
      ),
    );
  }

  Future<String> _saveTempFile() async {
    if (_tempFilePath != null) {
      final file = File(_tempFilePath!);
      if (file.existsSync()) {
        return _tempFilePath!;
      }
    }

    if (_fileBytes == null) {
      throw Exception('No file bytes available');
    }

    final tempDir = await getTemporaryDirectory();
    // Sanitize filename to avoid path issues
    final sanitizedFilename = widget.file.originalFilename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final file = File('${tempDir.path}/$sanitizedFilename');
    await file.writeAsBytes(_fileBytes!);
    _tempFilePath = file.path;
    return _tempFilePath!;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    String current = '';
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          current += '"';
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // End of field
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    // Add last field
    result.add(current.trim());
    return result;
  }

  Widget _buildViewer() {
    final fileType = widget.file.fileType.toLowerCase();

    switch (fileType) {
      case 'pdf':
        return _buildPdfViewer();
      case 'xlsx':
      case 'xls':
        // For Excel files on mobile, it's more reliable to open with external apps
        // The excel package can have issues with certain file formats or incomplete downloads
        return _buildExcelViewerWithFallback();
      case 'csv':
        return _buildCsvViewer();
      default:
        return _buildUnsupportedViewer();
    }
  }

  /// Excel viewer with automatic fallback to external app if decoding fails
  Widget _buildExcelViewerWithFallback() {
    if (_fileBytes == null) {
      return const Center(child: Text('No file data'));
    }

    // Try to decode first, but if it fails, show option to open externally
    try {
      if (_fileBytes!.isEmpty) {
        return const Center(child: Text('File is empty'));
      }

      // Verify file integrity before attempting to decode
      debugPrint('Attempting to decode Excel file:');
      debugPrint('  File size: ${_fileBytes!.length} bytes');
      debugPrint('  File type: ${widget.file.fileType}');
      debugPrint('  Original filename: ${widget.file.originalFilename}');
      
      // Check if it's a ZIP file (XLSX format)
      if (_fileBytes!.length >= 2) {
        final isZip = _fileBytes![0] == 0x50 && _fileBytes![1] == 0x4B; // PK signature
        debugPrint('  ZIP signature detected: $isZip');
        
        if (!isZip && (widget.file.fileType.toLowerCase() == 'xlsx' || 
            widget.file.originalFilename.toLowerCase().endsWith('.xlsx'))) {
          debugPrint('WARNING: XLSX file does not have valid ZIP signature!');
          // File is corrupted, show external open option
          return _buildExcelExternalOpenOption(
            'Invalid XLSX file: File does not appear to be a valid Excel file. The file may be corrupted.',
          );
        }
      }
      
      // Try to decode the Excel file
      debugPrint('Decoding Excel file...');
      final excel = Excel.decodeBytes(_fileBytes!);
      final sheets = <String>[];

      // Get all sheet names
      for (var sheetName in excel.sheets.keys) {
        sheets.add(sheetName);
      }

      if (sheets.isEmpty) {
        return _buildExcelExternalOpenOption('No sheets found in Excel file. Try opening with an external app.');
      }

      // Successfully decoded - show the viewer
      return DefaultTabController(
        length: sheets.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: sheets.map((name) => Tab(text: name)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: sheets.map((sheetName) {
                  final sheet = excel.sheets[sheetName];
                  if (sheet == null) {
                    return const Center(child: Text('Sheet not found'));
                  }
                  return _buildExcelTable(sheet);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      // If decoding fails, show option to open with external app
      debugPrint('Excel viewer error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stackTrace');
      
      return _buildExcelExternalOpenOption(
        'Unable to display Excel file in-app. This may be due to file format compatibility or incomplete download.',
        error: e.toString(),
      );
    }
  }

  /// Show option to open Excel file with external app
  Widget _buildExcelExternalOpenOption(String message, {String? error}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.table_chart, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Error: $error',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'File size: ${_fileBytes?.length ?? 0} bytes',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveAndOpenFile,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open with Excel/Sheets App'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadFile,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.originalFilename,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveAndOpenFile,
            tooltip: 'Download',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File: ${widget.file.originalFilename}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loadFile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _fileBytes != null ? _saveAndOpenFile : null,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open Externally'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : _fileBytes == null || _fileBytes!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          const Text('No file data available'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadFile,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _buildViewer(),
    );
  }
}

