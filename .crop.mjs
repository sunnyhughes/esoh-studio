import sharp from "sharp";
const [file, x0, y0, x1, y1, out] = process.argv.slice(2);
const { width: W, height: H } = await sharp(file).metadata();
await sharp(file).flatten({ background: "#ffffff" })
  .extract({ left: Math.round(W*+x0), top: Math.round(H*+y0),
             width: Math.round(W*(+x1-+x0)), height: Math.round(H*(+y1-+y0)) })
  .jpeg({ quality: 95 }).toFile(out);
