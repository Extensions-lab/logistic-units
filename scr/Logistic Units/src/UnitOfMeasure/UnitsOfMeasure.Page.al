
page 71628576 "TMAC Units Of Measure"
{
    Caption = 'Units of Measure (Logistic Units)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "TMAC Unit of Measure";
    
    AboutTitle = 'Units of Measure';
    AboutText = 'The Unit of Measure entity is a comprehensive measurement system designed for transportation and logistics management. It defines standardized units of measurement across four categories: Linear (length), Area, Volume, and Mass. Each unit includes a conversion factor to transform values into metric base units (meters, cubic meters, kilograms), and configurable rounding precision. The system supports unit conversion between different measurement types, including specialized functions for converting linear measurements to volume (using cubic calculations) and converting to/from system base units. This entity serves as the foundation for consistent measurement handling throughout the logistics application, ensuring accurate calculations and standardized reporting across different measurement systems and international standards.';
    
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("International Standard Code"; Rec."International Standard Code")
                {
                    ApplicationArea = All;
                }
                field("Caption"; Rec."Caption")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Value Rounding Precision"; Rec."Value Rounding Precision")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 6;
                }
                field("Conversion Factor"; Rec."Conversion Factor")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}