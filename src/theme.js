import { red } from "@mui/material/colors";
import { createTheme } from "@mui/material/styles";

// A custom theme for this app
const theme = createTheme({
  palette: {
    primary: {
      main: "#151515",
    },
    secondary: {
      main: "#1E1E1E",
    },
    tertiary: {
      main: '#182CEB',
    },
    error: {
      main: red.A400,
    },
  },
  typography: {
    h1: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    h2: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    h3: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    h4: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    h5: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    body: {
      color: "white",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
    body2: {
      color: "#747474",
      fontFamily: '"Roboto", "Helvetica", "Arial", "sans-serif"'
    },
  },
});

export default theme;

