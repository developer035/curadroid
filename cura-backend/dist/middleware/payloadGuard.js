"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.payloadGuard = void 0;
// Express body-parser size limit only checks the body after parsing.
// We also want to reject early or verify Content-Length if available.
const payloadGuard = (maxBytes = 4096) => {
    return (req, res, next) => {
        const contentLength = req.headers['content-length'];
        if (contentLength && parseInt(contentLength, 10) > maxBytes) {
            res.status(413).json({ error: 'Payload Too Large. Max size is 4KB.' });
            return;
        }
        next();
    };
};
exports.payloadGuard = payloadGuard;
