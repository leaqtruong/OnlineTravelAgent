import prisma from "../config/prisma.js";

export const reviewStore = {
  async getReviews(targetType: string, targetId: string) {
    const reviews = await prisma.review.findMany({
      where: { targetType, targetId },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { createdAt: "desc" },
    });

    const total = reviews.length;
    const avgRating = total > 0 ? reviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;

    return { reviews, total, avgRating: Math.round(avgRating * 10) / 10 };
  },

  async createReview(
    userId: string | undefined,
    targetType: string,
    targetId: string,
    rating: number,
    comment: string,
  ) {
    if (!userId) {
      throw new Error("Authentication required to create a review");
    }

    return prisma.review.upsert({
      where: {
        userId_targetType_targetId: { userId, targetType, targetId },
      },
      update: { rating, comment },
      create: { userId, targetType, targetId, rating, comment },
      include: { user: { select: { id: true, name: true } } },
    });
  },

  async deleteReview(userId: string | undefined, reviewId: string) {
    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review || review.userId !== userId) return null;
    await prisma.review.delete({ where: { id: reviewId } });
    return true;
  },
};
