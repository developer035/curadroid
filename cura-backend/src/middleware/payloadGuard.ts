import { Request, Response, NextFunction } from 'express';

// Express body-parser size limit only checks the body after parsing.
// We also want to reject early or verify Content-Length if available.
export const payloadGuard = (maxBytes = 4096) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const contentLength = req.headers['content-length'];
    if (contentLength && parseInt(contentLength, 10) > maxBytes) {
      res.status(413).json({ error: 'Payload Too Large. Max size is 4KB.' });
      return;
    }
    next();
  };
};
