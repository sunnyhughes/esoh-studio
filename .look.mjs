import sharp from "sharp";
await sharp(process.argv[2]).flatten({ background: "#808080" })
  .resize(1000, null, { withoutEnlargement: true }).jpeg({ quality: 92 })
  .toFile(process.argv[3]);
console.log("->", process.argv[3]);
