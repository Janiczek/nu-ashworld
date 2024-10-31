/** @type {import('tailwindcss').Config} */
export const content = ["../../src/**/*.elm"];
export const theme = {
  colors: {
    transparent: "transparent",
    current: "currentColor",
    black: {
      DEFAULT: "#000000",
      transparent: "rgba(0, 0, 0, 0.25)",
    },
    green: {
      900: "#111810",
      800: "#10240C",
      //
      300: "#007C00",
      200: "#00C000",
      100: "#3CF800",
      //
      "800-half-transparent": "rgba(16, 36, 12, 0.5)",
      "300-half-transparent": "rgba(0, 124, 0, 0.5)",
    },
    yellow: {
      DEFAULT: "#FCFF2F",
      transparent: "rgba(252, 253, 125, 0.25)",
      "fully-transparent": "rgba(252, 253, 125, 0)",
    },
    orange: "#FF962D",
    red: "#FC0001",
  },
  fontSize: {
    /* https://github.com/evilmartians/mono?tab=readme-ov-file#font-size-and-legibility */
    lg: ["25px", "28px"],
  },
  fontFamily: {
    mono: "Martian Mono",
    sans: "Martian Mono",
  },
  fontWeight: {
    DEFAULT: 300,
    normal: 300,
    bold: 500,
  },
  //
  extend: {
    spacing: {
      15: "3.75rem",
    },
  },
};
