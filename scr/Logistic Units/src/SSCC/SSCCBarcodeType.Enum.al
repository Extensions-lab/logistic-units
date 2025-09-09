enum 71628581 "TMAC SSCC Barcode Type"
{
    Extensible = true;

    value(0; "None")
    {
        Caption = ' ';
    }

    /// <summary>
    /// Code 39 - An alpha-numeric barcode that encodes uppercase letters, numbers and some symbols; it is also referred to as Barcode/39, the 3 of 9 Code and LOGMARS Code.
    /// </summary>
    value(1; "1D - Code39")
    {
        Caption = '1D - Code-39', Locked = true;
    }

    /// <summary>
    /// Codabar - A numeric barcode encoding numbers with a slightly higher density than Code 39.
    /// </summary>
    value(2; "1D - Codabar")
    {
        Caption = '1D - Codabar', Locked = true;
    }

    /// <summary>
    /// Code 128 - Alpha-numeric barcode with three character sets. Supports Code-128, GS1-128 (Formerly known as UCC/EAN-128) and ISBT-128.
    /// </summary>
    value(3; "1D - Code128")
    {
        Caption = '1D - Code-128', Locked = true;
    }

    /// <summary>
    /// Code 93 - Similar to Code 39, but requires two checksum characters.
    /// </summary>
    value(4; "1D - Code93")
    {
        Caption = '1D - Code-93', Locked = true;
    }

    /// <summary>
    /// Interleaved 2 of 5 - The Interleaved 2 of 5 barcode symbology encodes numbers in pairs, similar to Code 128 set C.
    /// </summary>
    value(5; "1D - Interleaved2of5")
    {
        Caption = '1D - Interleaved 2 of 5', Locked = true;
    }

    /// <summary>
    /// Postenet - The Intelligent Mail customer barcode combines the information of both the POSTNET and PLANET symbologies, and additional information, into a single barcode that is about the same size as the traditional POSTNET symbol. 
    /// </summary>
    value(6; "1D - Postnet")
    {
        Caption = '1D - Postnet', Locked = true;
    }

    /// <summary>
    /// MIS - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
    /// </summary>
    value(7; "1D - MSI")
    {
        Caption = '1D - MSI', Locked = true;
    }

    /// <summary>
    /// EAN-8 - The MSI Plessey barcode symbology was designed in the 1970s by the Plessey Company in England and has practiced primarily in libraries and retail applications. 
    /// </summary>
    value(8; "1D - EAN-8")
    {
        Caption = '1D - EAN-8', Locked = true;
    }

    /// <summary>
    /// EAN-13 - The EAN-13 was developed as a superset of UPC-A, adding an extra digit to the beginning of every UPC-A number. 
    /// </summary>
    value(9; "1D - EAN-13")
    {
        Caption = '1D - EAN-13', Locked = true;
    }

    /// <summary>
    /// UPC-A - The Universal Product Code (UPC; redundantly: UPC code) is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores.
    /// </summary>
    value(10; "1D - UPC-A")
    {
        Caption = '1D - UPC-A', Locked = true;
    }

    /// <summary>
    /// UPC-E -  To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a 'zero-suppressed version of UPC was developed, called UPC-E.
    /// </summary>
    value(11; "1D - UPC-E")
    {
        Caption = '1D - UPC-E', Locked = true;
    }

    // // <summary>
    // /// Aztec barcodes are very efficient two-dimensional (2D) symbologies that use square modules with a unique finder pattern in the middle of the symbol, which helps the barcode scanner to determine cell locations to decode the symbol.
    // /// Characters, numbers, text and bytes of data may be encoded in an Aztec barcode. The IDAutomation implementation of the Aztec barcode symbol is based on the ISO standard version released into the public domain by its inventor, Honeywell.
    // /// </summary>
    value(12; "2D - Aztec")
    {
        Caption = '2D - Aztec', Locked = true;
    }

    /// <summary>
    /// Data Matrix is a very efficient, two-dimensional (2D) barcode symbology that uses a small area of square modules with a unique perimeter pattern, which helps the barcode scanner determine cell locations and decode the symbol.
    /// Characters, numbers, text and actual bytes of data may be encoded, including Unicode characters and photos.
    /// The encoding and decoding process of Data Matrix is very complex. Several methods have been used for error correction in the past. All current implementations have been standardized on the ECC200 error correction method, which is approved by ANSI/AIM BC11 and the ISO/IEC 16022 specification.
    /// IDAutomation 2D Data Matrix barcode products all support ECC200 by default and are based on the ANSI/AIM BC11 and the ISO/IEC 16022 specifications. The Reed-Solomon error correction algorithms of ECC200 allow the recognition of barcodes that are up to 60% damaged.
    /// </summary>
    value(13; "2D - Data Matrix")
    {
        Caption = '2D - Data Matrix', Locked = true;
    }

    /// <summary>
    /// Maxicode is an international 2D (two-dimensional) barcode that is currently used by UPS on shipping labels for world-wide addressing and package sortation. MaxiCode symbols are fixed in size and are made up of offset rows of hexagonal modules arranged around a unique finder pattern.
    /// MaxiCode includes error correction, which enables the symbol to be decoded when it is slightly damaged.
    /// </summary>
    value(14; "2D - Maxi Code")
    {
        Caption = '2D - Maxi Code', Locked = true;
    }

    /// <summary>
    /// The PDF417 barcode is a two-dimensional (2D), high-density symbology capable of encoding text, numbers, files and actual data bytes.
    /// Large amounts of text and data can be stored securely and inexpensively when using the PDF417 barcode symbology. The printed symbol consists of several linear rows of stacked codewords. Each codeword represents 1 of 929 possible values from one of three different clusters.
    /// A different cluster is chosen for each row, repeating after every three rows. Because the codewords in each cluster are unique, the scanner is able to determine what line each cluster is from.
    /// </summary>
    value(15; "2D - PDF417")
    {
        Caption = '2D - PDF417', Locked = true;
    }

    /// <summary>
    /// QR-Code is a two-dimensional (2D) barcode type similar to Data Matrix or Aztec, which is capable of encoding large amounts of data. QR means Quick Response, as the inventor intended the symbol to be quickly decoded. The data encoded in a QR-Code may include alphabetic characters, text, numbers, double characters and URLs.
    /// The symbology uses a small area of square modules with a unique perimeter pattern, which helps the barcode scanner determine cell locations to decode the symbol. IDAutomation’s implementation of QR-Code is based on the ISO/IEC 18004:2006 standard (also known as QR-Code 2005) and conforms to ISO/IEC 18004:2015 specifications.
    /// </summary>
    value(16; "2D - QR-Code")
    {
        Caption = '2D - QR-Code', Locked = true;
    }
}
