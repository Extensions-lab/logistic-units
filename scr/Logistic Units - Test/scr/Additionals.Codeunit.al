/// <summary>
/// Тест различных элементов
/// </summary>
codeunit 71629500 "TMAC Additional"
{
    Subtype = Test;
    TestPermissions = Disabled; //ахахахаха а вот хуй знает зачем., без этого с 22 года не работает


    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenFreightClass()
    var
        FreightClasses: TestPage "TMAC Freight Class List";
    begin
        //[Given] 
        FreightClasses.OpenEdit();
        FreightClasses.Code.Activate();
        FreightClasses.Code.SetValue('TEST');
        FreightClasses.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenLogisticUnitSetup()
    var
        LogisticUnitsSetup: TestPage "TMAC Logistic Units Setup";
    begin
        //[Given] 
        LogisticUnitsSetup.OpenEdit();
        LogisticUnitsSetup.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitsOfMeasure()
    var
        UnitsOfMeasure: TestPage "TMAC Units Of Measure";
    begin
        //[Given] 
        UnitsOfMeasure.OpenEdit();
        UnitsOfMeasure.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitsLocationAnalysis()
    var
        UnitsLocationAnalysis: TestPage "TMAC Units Location Analysis";
    begin
        //[Given] 
        UnitsLocationAnalysis.OpenView();
        UnitsLocationAnalysis.Update.Invoke();
        UnitsLocationAnalysis.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitActions()
    var
        UnitActions: TestPage "TMAC Unit Actions";
    begin
        //[Given] 
        UnitActions.OpenEdit();
        UnitActions.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenSSCC()
    var
        SSCCCard: TestPage "TMAC SSCC Card";
    begin
        //[Given] 
        SSCCCard.OpenNew();
        SSCCCard.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitLocations()
    var
        UnitLocations: TestPage "TMAC Unit Locations";
    begin
        //[Given] 
        UnitLocations.OpenView();
        UnitLocations.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitWorksheetNamesList()
    var
        UnitWorksheetNamesList: TestPage "TMAC Unit Worksheet Names List";
    begin
        //[Given] 
        UnitWorksheetNamesList.OpenView();
        UnitWorksheetNamesList.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitWorksheets()
    var
        UnitWorksheets: TestPage "TMAC Unit Worksheets";
    begin
        //[Given] 
        UnitWorksheets.OpenView();
        UnitWorksheets.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenUnitTypeCard()
    var
        UnitTypeCard: TestPage "TMAC Unit Type Card";
    begin
        UnitTypeCard.OpenView();
        UnitTypeCard.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenPostedUnitCard()
    var
        PostedUnitCard: TestPage "TMAC Posted Unit Card";
    begin
        PostedUnitCard.OpenView();
        PostedUnitCard.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenPostedUnitList()
    var
        PostedUnitList: TestPage "TMAC Posted Unit List";
    begin
        PostedUnitList.OpenView();
        PostedUnitList.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure OpenAssistedSetup()
    var
        AssistedSetup: TestPage "TMAC Assisted Setup";
    begin
        AssistedSetup.OpenView();
        AssistedSetup.Close();
    end;

    var
        Framework: Codeunit "TMAC Framework";
        LibraryERM: Codeunit "Library - ERM";

}