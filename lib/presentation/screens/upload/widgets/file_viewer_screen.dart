import 'dart:io';
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

      if (fileBytes != null) {
        setState(() {
          _fileBytes = Uint8List.fromList(fileBytes);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load file';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndOpenFile() async {
    if (_fileBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${widget.file.originalFilename}');
      await file.writeAsBytes(_fileBytes!);
      _tempFilePath = file.path;

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.error,
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
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return SfPdfViewer.file(File(snapshot.data!));
      },
    );
  }

  Widget _buildExcelViewer() {
    if (_fileBytes == null) {
      return const Center(child: Text('No file data'));
    }

    try {
      final excel = Excel.decodeBytes(_fileBytes!);
      final sheets = <String>[];

      // Get all sheet names
      for (var sheetName in excel.sheets.keys) {
        sheets.add(sheetName);
      }

      if (sheets.isEmpty) {
        return const Center(child: Text('No sheets found'));
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
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error reading Excel file: $e'),
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
      final content = String.fromCharCodes(_fileBytes!);
      final lines = content.split('\n');
      
      if (lines.isEmpty) {
        return const Center(child: Text('Empty CSV file'));
      }

      // Parse header
      final header = lines[0].split(',').map((e) => e.trim()).toList();
      
      // Parse rows (limit to 1000 for performance)
      final dataRows = lines.skip(1).take(1000).map((line) {
        return line.split(',').map((e) => e.trim()).toList();
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
      return _tempFilePath!;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${widget.file.originalFilename}');
    await file.writeAsBytes(_fileBytes!);
    _tempFilePath = file.path;
    return _tempFilePath!;
  }

  Widget _buildViewer() {
    final fileType = widget.file.fileType.toLowerCase();

    switch (fileType) {
      case 'pdf':
        return _buildPdfViewer();
      case 'xlsx':
      case 'xls':
        return _buildExcelViewer();
      case 'csv':
        return _buildCsvViewer();
      default:
        return _buildUnsupportedViewer();
    }
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
                      Text(
                        _error!,
                        style: AppTextStyles.bodyLarge,
                      ),
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

