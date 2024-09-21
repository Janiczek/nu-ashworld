tailwind.config = {
    theme: {
        colors: {
            transparent: "transparent",
            current: "currentColor",
            black: "#000000",
            green: {
                900: "#111810",
                800: "#10240C",
                //
                300: "#007C00",
                200: "#00C000",
                100: "#3CF800",
            },
            orange: "#FCFF2F",
        },
        fontSize: {
            lg: "32px",
        },
        fontFamily: {
            mono: "PixelOperatorMono",
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
    },
}