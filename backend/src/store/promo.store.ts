import prisma from "../config/prisma.js";

export const promoStore = {
  async checkPromoCode(code: string) {
    const promo = await prisma.promoCode.findUnique({ where: { code } });
    if (!promo || !promo.isActive) return { error: "Mã giảm giá không hợp lệ" };
    if (promo.validUntil && promo.validUntil < new Date()) {
      return { error: "Mã giảm giá đã hết hạn" };
    }
    if (promo.currentUses >= promo.maxUses) return { error: "Mã giảm giá đã hết lượt sử dụng" };
    return { promo };
  },

  async applyPromoCode(code: string) {
    await prisma.promoCode.update({
      where: { code },
      data: { currentUses: { increment: 1 } },
    });
  },
};
