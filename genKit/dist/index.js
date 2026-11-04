"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const multer_1 = __importDefault(require("multer"));
const dotenv_1 = __importDefault(require("dotenv"));
const receiptParser_flow_js_1 = require("./flows/receiptParser.flow.js");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
// Configure Multer for in-memory file uploads (max 20MB per file)
const upload = (0, multer_1.default)({
    storage: multer_1.default.memoryStorage(),
    limits: { fileSize: 20 * 1024 * 1024 },
});
// Middleware
app.use((0, cors_1.default)());
app.use(express_1.default.json({ limit: '50mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '50mb' }));
// Health Check Endpoint
app.get('/health', (_req, res) => {
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
app.post('/api/parse-receipt', upload.single('receipt'), async (req, res) => {
    try {
        let imageBase64 = req.body.imageBase64;
        let mimeType = req.body.mimeType || 'image/jpeg';
        const ocrText = req.body.ocrText;
        // Handle file upload if present
        if (req.file) {
            imageBase64 = req.file.buffer.toString('base64');
            mimeType = req.file.mimetype;
        }
        if (!imageBase64 && !ocrText) {
            res.status(400).json({
                success: false,
                error: 'Missing receipt input. Please upload a receipt file, provide imageBase64, or supply ocrText.',
            });
            return;
        }
        console.log(`[${new Date().toISOString()}] Processing receipt (File attached: ${Boolean(req.file)}, Base64 present: ${Boolean(imageBase64)}, OCR text present: ${Boolean(ocrText)})`);
        // Execute Genkit Flow
        const parsedReceipt = await (0, receiptParser_flow_js_1.parseReceiptFlow)({
            imageBase64: imageBase64 || undefined,
            mimeType: mimeType || undefined,
            ocrText: ocrText || undefined,
        });
        res.status(200).json({
            success: true,
            data: parsedReceipt,
        });
    }
    catch (error) {
        console.error('Error parsing receipt:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'An error occurred while parsing the receipt.',
        });
    }
});
// Fallback error handler
app.use((err, _req, res, _next) => {
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
