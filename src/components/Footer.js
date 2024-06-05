import React from "react";

function Footer() {
  const year = new Date().getFullYear();
  return (
    <footer>
      {/* <div class="footer-content">
        <h3></h3>
      </div>
    */}
      <div class="footer-bottom">
        <p>copyright &copy; {year}</p>
      </div>
    </footer>
  );
}

export default Footer;
