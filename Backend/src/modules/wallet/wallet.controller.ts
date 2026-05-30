import prisma from "../../config/prisma";


// GET BALANCE

export const getBalance = async (
  req: any,
  res: any
) => {
  try {
    const userId = req.user.id;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { walletBalance: true },
    });

    res.json({
      balance: user?.walletBalance || 0,
    });

  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch balance",
    });
  }
};


// TOP UP

export const topUpWallet = async (
  req: any,
  res: any
) => {
  try {
    const userId = req.user.id;
    const { amount } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({
        message: "Invalid amount",
      });
    }

    await prisma.user.update({
      where: { id: userId },
      data: {
        walletBalance: {
          increment: Number(amount),
        },
      },
    });

    await prisma.walletTransaction.create({
      data: {
        userId,
        amount: Number(amount),
        type: "TOPUP",
        note: "Wallet top-up",
      },
    });

    res.json({
      message: "Wallet funded successfully",
    });

  } catch (error) {
    res.status(500).json({
      message: "Top-up failed",
    });
  }
};


// HISTORY

export const getHistory = async (
  req: any,
  res: any
) => {
  try {
    const userId = req.user.id;

    const history =
      await prisma.walletTransaction.findMany({
        where: { userId },
        orderBy: {
          createdAt: "desc",
        },
      });

    res.json(history);

  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch history",
    });
  }
};