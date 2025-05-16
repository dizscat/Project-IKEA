-- -----------------------------------------------------
-- Schema ikea_inventory
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ikea_inventory` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ikea_inventory`;

-- -----------------------------------------------------
-- Table `supplier`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `supplier` (
  `id_supplier` INT NOT NULL AUTO_INCREMENT,
  `nama_supplier` VARCHAR(100) NOT NULL,
  `kontak_supplier` VARCHAR(20) NOT NULL,
  `alamat_supplier` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id_supplier`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `barang`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `barang` (
  `id_barang` INT NOT NULL AUTO_INCREMENT,
  `id_supplier` INT NULL,
  `nama_barang` VARCHAR(100) NOT NULL,
  `kategori` VARCHAR(50) NOT NULL,
  `deskripsi` TEXT NULL,
  `harga_satuan` DECIMAL(12,2) NOT NULL,
  `satuan` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id_barang`),
  INDEX `fk_barang_supplier_idx` (`id_supplier` ASC),
  CONSTRAINT `fk_barang_supplier`
    FOREIGN KEY (`id_supplier`)
    REFERENCES `supplier` (`id_supplier`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `gudang`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `gudang` (
  `id_gudang` INT NOT NULL AUTO_INCREMENT,
  `nama_gudang` VARCHAR(100) NOT NULL,
  `lokasi` VARCHAR(200) NOT NULL,
  `kapasitas` INT NOT NULL,
  `jenis_gudang` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_gudang`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `toko`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `toko` (
  `id_toko` INT NOT NULL AUTO_INCREMENT,
  `nama_toko` VARCHAR(100) NOT NULL,
  `lokasi_toko` VARCHAR(200) NOT NULL,
  `manager_toko` VARCHAR(50) NOT NULL,
  `kontak_toko` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id_toko`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `stok`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stok` (
  `id_stok` INT NOT NULL AUTO_INCREMENT,
  `id_barang` INT NOT NULL,
  `id_gudang` INT NULL,
  `id_toko` INT NULL,
  `jumlah_stok` INT NOT NULL,
  `stok_minimal` INT NOT NULL,
  `tanggal_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_stok`),
  INDEX `fk_stok_barang_idx` (`id_barang` ASC),
  INDEX `fk_stok_gudang_idx` (`id_gudang` ASC),
  INDEX `fk_stok_toko_idx` (`id_toko` ASC),
  CONSTRAINT `fk_stok_barang`
    FOREIGN KEY (`id_barang`)
    REFERENCES `barang` (`id_barang`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_stok_gudang`
    FOREIGN KEY (`id_gudang`)
    REFERENCES `gudang` (`id_gudang`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_stok_toko`
    FOREIGN KEY (`id_toko`)
    REFERENCES `toko` (`id_toko`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_lokasi_stok`
    CHECK (
      (`id_gudang` IS NOT NULL AND `id_toko` IS NULL) OR 
      (`id_toko` IS NOT NULL AND `id_gudang` IS NULL)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `transaksi_inventaris`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `transaksi_inventaris` (
  `id_transaksi` INT NOT NULL AUTO_INCREMENT,
  `id_barang` INT NOT NULL,
  `id_gudang` INT NOT NULL,
  `tanggal_transaksi` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `jenis_transaksi` ENUM('Masuk', 'Keluar', 'Pemindahan') NOT NULL,
  `jumlah_transaksi` INT NOT NULL,
  PRIMARY KEY (`id_transaksi`),
  INDEX `fk_transaksi_barang_idx` (`id_barang` ASC),
  INDEX `fk_transaksi_gudang_idx` (`id_gudang` ASC),
  CONSTRAINT `fk_transaksi_barang`
    FOREIGN KEY (`id_barang`)
    REFERENCES `barang` (`id_barang`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_transaksi_gudang`
    FOREIGN KEY (`id_gudang`)
    REFERENCES `gudang` (`id_gudang`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `distribusi_barang`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `distribusi_barang` (
  `id_distribusi` INT NOT NULL AUTO_INCREMENT,
  `id_transaksi` INT NOT NULL,
  `id_gudang` INT NOT NULL,
  `id_toko` INT NOT NULL,
  `tanggal_distribusi` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_distribusi` ENUM('Dalam Proses', 'Selesai', 'Tertunda') NOT NULL,
  PRIMARY KEY (`id_distribusi`),
  INDEX `fk_distribusi_transaksi_idx` (`id_transaksi` ASC),
  INDEX `fk_distribusi_gudang_idx` (`id_gudang` ASC),
  INDEX `fk_distribusi_toko_idx` (`id_toko` ASC),
  CONSTRAINT `fk_distribusi_transaksi`
    FOREIGN KEY (`id_transaksi`)
    REFERENCES `transaksi_inventaris` (`id_transaksi`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_distribusi_gudang`
    FOREIGN KEY (`id_gudang`)
    REFERENCES `gudang` (`id_gudang`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_distribusi_toko`
    FOREIGN KEY (`id_toko`)
    REFERENCES `toko` (`id_toko`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `performa_toko`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `performa_toko` (
  `id_performa` INT NOT NULL AUTO_INCREMENT,
  `id_toko` INT NOT NULL,
  `rating` DECIMAL(3,2) NOT NULL,
  `tanggal_feedback` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_performa`),
  INDEX `fk_performa_toko_idx` (`id_toko` ASC),
  CONSTRAINT `fk_performa_toko`
    FOREIGN KEY (`id_toko`)
    REFERENCES `toko` (`id_toko`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `pengguna`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pengguna` (
  `id_pengguna` INT NOT NULL AUTO_INCREMENT,
  `nama_lengkap` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `kata_sandi` VARCHAR(255) NOT NULL,
  `nomor_telepon` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`id_pengguna`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)
) ENGINE = InnoDB;