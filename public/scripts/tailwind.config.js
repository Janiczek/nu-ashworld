/** @type {import('tailwindcss').Config} */
export const content = ['../../src/**/*.elm'];
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
            "300-half-transparent": "rgba(0, 124, 0, 0.5)",
        },
        orange: {
            DEFAULT: "#FCFF2F",
            transparent: "rgba(252, 253, 125, 0.25)",
        },
        red: "#FC0001",
    },
    fontSize: {
        lg: "32px",
    },
    fontFamily: {
        mono: "PixelOperatorMono",
        sans: "PixelOperator",
    },
    fontWeight: {
        normal: 400,
        bold: 700,
        extraBold: 900,
    },
    //
    extend: {
        spacing: {
            15: '3.75rem',
        }
    }
};