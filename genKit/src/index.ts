import express, { Request, Response } from 'express';
import cors from 'cors';
import multer from 'multer';
import dotenv from 'dotenv';
import { parseReceiptFlow } from './flows/receiptParser.flow.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configure Multer for in-memory file uploads (max 20MB per file)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024 },
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Health Check Endpoint
app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'ok',
    service: 'ReceiptVault Genkit Server',
    timestamp: new Date().toISOString(),
  });
});

/**
 * POST /api/parse-receipt
 * Supports:
 * 1. JSON payload: { imageBase64: "...", mimeType: "image/jpeg", ocrText: "..." }
 * 2. Multipart form-data: upload single file with field name 'receipt' or 'file'
 */
app.post(
  '/api/parse-receipt',
  upload.single('receipt'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      let imageBase64: string | undefined = req.body.imageBase64;
      let mimeType: string | undefined = req.body.mimeType || 'image/jpeg';
      const ocrText: string | undefined = req.body.ocrText;

      // Handle file upload if present
      if (req.file) {
        imageBase64 = req.file.buffer.toString('base64');
        mimeType = req.file.mimetype;
      }

      if (!imageBase64 && !ocrText) {
        res.status(400).json({
          success: false,
          error:
            'Missing receipt input. Please upload a receipt file, provide imageBase64, or supply ocrText.',
        });
        return;
      }

      console.log(
        `[${new Date().toISOString()}] Processing receipt (File attached: ${Boolean(
          req.file
        )}, Base64 present: ${Boolean(imageBase64)}, OCR text present: ${Boolean(
          ocrText
        )})`
      );

      // Execute Genkit Flow
      const parsedReceipt = await parseReceiptFlow({
        imageBase64: imageBase64 || undefined,
        mimeType: mimeType || undefined,
        ocrText: ocrText || undefined,
      } as any);

      res.status(200).json({
        success: true,
        data: parsedReceipt,
      });
    } catch (error: any) {
      console.error('Error parsing receipt:', error);
      res.status(500).json({
        success: false,
        error: error.message || 'An error occurred while parsing the receipt.',
      });
    }
  }
);

// Fallback error handler
app.use((err: any, _req: Request, res: Response, _next: any) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({
    success: false,
    error: err.message || 'Internal Server Error',
  });
});

app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 ReceiptVault Genkit Server running on port ${PORT}`);
  console.log(`📡 Health Check: http://localhost:${PORT}/health`);
  console.log(`🧾 Parse API:    POST http://localhost:${PORT}/api/parse-receipt`);
  console.log(`=======================================================`);
});
