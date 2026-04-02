export const STRAPI_URL = process.env.NEXT_PUBLIC_API_URL!;

export async function fetchAPI(path: string) {
  const res = await fetch(`${STRAPI_URL}/api${path}`, {
    next: { revalidate: 60 }
  });

  if (!res.ok) throw new Error("Failed to fetch from Strapi");

  return res.json();
}
