import React from "react";
import Header from "./Header";
import { Container } from "semantic-ui-react";
import Footer from "./Footer";

export default (props) => {
  return (
    <Container>
      <Header />
      {props.children}
      <Footer />
    </Container>
  );
};
