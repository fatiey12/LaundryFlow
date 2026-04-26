import { Request, Response, NextFunction } from "express";

export const requireRole = (roles: string[]) => {
  return (req: any, res: any, next: any) => {
    const user = req.user;

    if (!user || !roles.includes(user.role)) {
      return res.status(403).json({
        message: `Access denied: ${roles.join(", ")} only`,
      });
    }

    next();
  };
};