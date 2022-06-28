import * as React from "react";
import Container from "@mui/material/Container";
import Typography from "@mui/material/Typography";
import Box from "@mui/material/Box";
import Link from "@mui/material/Link";
import BuyModal from "./BuyModal";

export default function App() {
  return (
    <Container className="app-container">
      <Box
        sx={{
          my: 4,
          display: "flex",
          flexDirection: 'column',
          alignItems: "center",
          justifyContent: "center",
          alignText: "center",
        }}
      >
        <Typography variant="h4" component="h1" gutterBottom>
          Hey Dopies
        </Typography>
        <BuyModal />
      </Box>
    </Container>
  );
}

