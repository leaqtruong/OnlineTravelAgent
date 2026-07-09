import prisma from "../config/prisma.js";
import { generateId } from "./helpers.js";

export const documentStore = {
  async getDocuments(userId?: string) {
    if (!userId) return [];
    return prisma.documentItem.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
  },

  async createDocument(
    userId: string | undefined,
    title: string,
    description: string,
    icon: string,
    color: string,
  ) {
    if (!userId) {
      throw new Error("Authentication required to create a document");
    }

    return prisma.documentItem.create({
      data: {
        id: generateId("doc"),
        title,
        description,
        icon,
        color,
        userId,
      },
    });
  },

  async deleteDocument(userId: string | undefined, id: string) {
    if (!userId) return false;
    const result = await prisma.documentItem.deleteMany({ where: { id, userId } });
    return result.count > 0;
  },
};
