"use client";

import { useEffect } from "react";

export type Theme = "system" | "light" | "dark";

const choices = [
  { value: "system", label: "System" },
  { value: "light", label: "Light" },
  { value: "dark", label: "Dark" },
] as const;

function setPressed(theme: Theme) {
  for (const button of document.querySelectorAll<HTMLElement>(
    "[data-theme-choice]",
  )) {
    button.setAttribute(
      "aria-pressed",
      String(button.dataset.themeChoice === theme),
    );
  }
}

/*
  The root attribute is what the tokens key off, so a click writes both the
  cookie (next load) and the attribute (this load). The selected button is
  styled from that attribute in CSS, which is why there is no React state here
  to fall out of sync.
*/
function store(theme: Theme) {
  document.cookie = `theme=${theme}; path=/; max-age=31536000; samesite=lax`;

  if (theme === "system") {
    delete document.documentElement.dataset.theme;
  } else {
    document.documentElement.dataset.theme = theme;
  }

  setPressed(theme);
}

export function ThemeToggle() {
  // The inline script in the root layout applied the cookie before paint; this
  // only brings aria-pressed in line with it.
  useEffect(() => {
    const current = document.documentElement.dataset.theme;

    setPressed(current === "light" || current === "dark" ? current : "system");
  }, []);

  return (
    <div
      role="group"
      aria-label="Theme"
      className="flex items-center gap-0.5 rounded border border-border p-0.5"
    >
      {choices.map((choice) => (
        <button
          key={choice.value}
          type="button"
          data-theme-choice={choice.value}
          onClick={() => store(choice.value)}
          aria-pressed={false}
          className="rounded px-1.5 py-0.5 text-[11px] text-muted-foreground hover:text-foreground"
        >
          {choice.label}
        </button>
      ))}
    </div>
  );
}
