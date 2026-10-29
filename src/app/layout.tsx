import { ClerkProvider } from "@clerk/nextjs";
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "explain-codebase",
  description: "A real dependency map of a codebase you didn't write.",
};

/*
  Runs before the body paints. Without it a forced theme would flash the
  system one on every reload, which is exactly what the control promises not
  to do. The cookie is the only source of truth; the server doesn't read it.
*/
const themeScript = `try{var m=document.cookie.match(/(?:^|;\\s*)theme=(system|light|dark)/);if(m&&m[1]!=="system"){document.documentElement.dataset.theme=m[1]}}catch(e){}`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html
      lang="en"
      // The theme script sets data-theme on this element before hydration, so
      // React must not treat the difference as a mismatch.
      suppressHydrationWarning
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col">
        <script dangerouslySetInnerHTML={{ __html: themeScript }} />
        <ClerkProvider>{children}</ClerkProvider>
      </body>
    </html>
  );
}
