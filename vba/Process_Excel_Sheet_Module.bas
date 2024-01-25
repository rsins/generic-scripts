Attribute VB_Name = "Process_Excel_Sheet_Module"
Dim Current_sheet As Worksheet

Sub Process_Excel_Sheet() '
Attribute Process_Excel_Sheet.VB_ProcData.VB_Invoke_Func = "r\n14"
' Process_Excel_Sheet Macro
' Macro recorded 1/24/2008 by Ravi
' Modified multiple times by Ravi
'

    Dim parameter As String
   
    Set Current_sheet = ActiveWorkbook.ActiveSheet
    
    parameter = InputBox("1__ Freeze panes & Autofit first 5 columns" & Chr(10) & _
                         "1n_ Option 1 above with rename sheet" & Chr(10) & _
                         "2__ Freeze panes & set filter on first row" & Chr(10) & _
                         "2n_ Option 2 above with rename sheet" & Chr(10) & _
                         "3__ Compare two sheets (Sheets already sorted " & Chr(10) & _
                         "       and First column non-blank)" & Chr(10) & _
                         "3n_ Compare two sheets with customized options." & Chr(10) & _
                         "4__ Remove bold and color background of the cells" & Chr(10) & _
                         "       in the current sheet." & Chr(10) & _
                         "4n_ Remove bold and color background of the cells" & Chr(10) & _
                         "       in first two sheets." & Chr(10) & _
                         "5__ Check for Filter Conditions in Header Row." & Chr(10) & _
                         "5n_ Option 5 above with ask user for header row if not" & Chr(10) & _
                         "       1st row." & Chr(10) & _
                         "5m_ Option 5 and 5n above with ask user for column" & Chr(10) & _
                         "       numbers to remove filters from." & Chr(10) & _
                         "6__ On Active Sheet apply blank pattern and border." & Chr(10) & _
                         "6n_ On Active Sheet apply blank pattern only." & Chr(10) & _
                         "7__ Re-Open current csv file data in new workbook as text.", _
                         "What to Process..", _
                         "")
    
    Select Case parameter
        ' RuleTree setting.
        Case "1", "1n", "1N"
            If (parameter = "1n" Or parameter = "1N") Then
                Call new_Sheet_Name
            End If
            
            Columns("A:A").EntireColumn.AutoFit
            Columns("B:B").EntireColumn.AutoFit
            Columns("C:C").EntireColumn.AutoFit
            Columns("D:D").EntireColumn.AutoFit
            Columns("E:E").EntireColumn.AutoFit
            Rows("2:2").Select
            ActiveWindow.FreezePanes = True
            Range("A2").Select
  
        ' ResultTable setting.
        Case "2", "2n", "2N"
            If (parameter = "2n" Or parameter = "2N") Then
                Call new_Sheet_Name
            End If
            
            If Trim(Cells(1, 1).Value) <> "" Then
                Rows("2:2").Select
                ActiveWindow.FreezePanes = True
                Cells.Select
                Selection.AutoFilter Field:=1, VisibleDropDown:=True
                Range("A2").Select
            End If
        
        ' Compare two sheets.
        Case "3"
            Call Compare_Two_Sheets("NA")
            
        ' Compare two sheets.
        Case "3n", "3N"
            Call Compare_Two_Sheets("Y")

        ' Remove all the color and bold font from the cells on current sheet.
        Case "4"
            Cells.Select
            Selection.Font.Bold = False
            Selection.Interior.ColorIndex = xlNone
            ActiveWindow.FreezePanes = False
            Range("A1").Select
            
        ' Remove all the color and bold font from the cells.
        Case "4n", "4N"
            'First sheet
            ActiveWorkbook.Sheets(1).Activate
            Cells.Select
            Selection.Font.Bold = False
            Selection.Interior.ColorIndex = xlNone
            ActiveWindow.FreezePanes = False
            Range("A1").Select
            'Second sheet
            ActiveWorkbook.Sheets(2).Activate
            Cells.Select
            Selection.Font.Bold = False
            Selection.Interior.ColorIndex = xlNone
            ActiveWindow.FreezePanes = False
            Range("A1").Select
            'Get to the current sheet
            Current_sheet.Activate
            Range("A1").Select
        Case "5"
            Call CheckForFilterConditionsInHeaderRow(False, False)
        Case "5n", "5N"
            Call CheckForFilterConditionsInHeaderRow(True, False)
        Case "5m", "5M"
            Call CheckForFilterConditionsInHeaderRow(True, True)
        Case "6"
            Call ActiveSheetBlankPatternAndBorderOnUsedRange(True)
        Case "6n", "6N"
            Call ActiveSheetBlankPatternAndBorderOnUsedRange(False)
        Case "7"
            Call ReOpenCurrentCSVFileWithAllColumnsAsText
        Case Else
    End Select
End Sub


' Subroutine to Rename the current sheet.
Private Sub new_Sheet_Name()
    Dim sheetname As String
    
    sheetname = InputBox("New Name for the Active Sheet:" & Chr(10) & "Press Enter or Escape for no change.", "New Sheet Name..", ActiveWorkbook.ActiveSheet.Name)
    If Trim(sheetname) <> "" Then
        ActiveWorkbook.ActiveSheet.Name = Trim(sheetname)
    End If
End Sub

Private Sub Compare_Two_Sheets(user_input_parameter As String)  'value "Y" means ask for user input
' 1. This Macro assumes that the rows in the two sheets are already shorted.
' 2. Also the first column of the two sheets should not be blank.
' 3. And first row in each sheet should be the header. The number of columns to be
'    compared will be based on maximum of columns in header of the two sheets.
    
    ' Maximum number of columns or rows the comparison will be run through.
    Const MAX_COLUMNS = 100
    Const MAX_ROWS = 50000
    
    ' Define sheet objects.
    Dim s1 As Excel.Worksheet
    Dim s2 As Excel.Worksheet
    
    ' Define other variables.
    Dim s1_i As Long
    Dim s2_i As Long
    Dim last_match_sheet1 As Long
    Dim last_match_sheet2 As Long
    Dim Total_Num_Rows_Sheet1 As Long
    Dim Total_Num_Rows_Sheet2 As Long
    Dim sheet_START_ROW As Long
    Dim Sheet_MAX_ROWS As Long
    Dim Sheet_START_COLUMN As Long
    Dim Sheet_MAX_COLUMNS As Long
    Dim Sheet_Mark_Diff_Column_Num As Long
    Dim Sheet_Mark_Diff_Column_Flag As Boolean
    Dim j As Long
    Dim Final_Message As String
    
    ' Define user input variables.
    Dim user_input As String
    
    ' Define Boolean variables.
    Dim b_match_found As Boolean
    Dim Overall_Match_Found As Boolean
        
    ' Initialize variables.
    s1_i = 1
    s2_i = 1
    j = 1
    last_match_sheet1 = 0
    last_match_sheet2 = 0
    Total_Num_Rows_Sheet1 = 0
    Total_Num_Rows_Sheet2 = 0
    Overall_Match_Found = True
    Sheet_START_COLUMN = 1
    Sheet_MAX_COLUMNS = MAX_COLUMNS
    sheet_START_ROW = 1
    Sheet_MAX_ROWS = MAX_ROWS
    Final_Message = ""
    Sheet_Mark_Diff_Column_Flag = False
    
    ' Only one sheet present. Nothing to compare.
    If ActiveWorkbook.Sheets.Count < 2 Then
        MsgBox "There is no sheet to compare against.", vbOKOnly + vbCritical, "Macro"
        Exit Sub
    End If
    
    ' Initialize the objects pointing to the first two sheets.
    Set s1 = ActiveWorkbook.Sheets(1)
    Set s2 = ActiveWorkbook.Sheets(2)
    
    ' Number of rows in first sheet.
    While Trim(s1.Cells(s1_i, 1).Value) <> "" And s1_i <= Sheet_MAX_ROWS
        Total_Num_Rows_Sheet1 = Total_Num_Rows_Sheet1 + 1
        s1_i = s1_i + 1
    Wend
    
    ' Number of rows in second sheet.
    While Trim(s2.Cells(s2_i, 1).Value) <> "" And s2_i < Sheet_MAX_ROWS
        Total_Num_Rows_Sheet2 = Total_Num_Rows_Sheet2 + 1
        s2_i = s2_i + 1
    Wend
    
    ' Find out how many columns in first sheet. Assuming that first row is header row.
    j = 0
    While j <= MAX_COLUMNS And Trim(s1.Cells(1, j + 1).Value) <> ""
        j = j + 1
    Wend
    Sheet_MAX_COLUMNS = j
    
    ' Find out how many columns in the second sheet. Assuming that first row is header row.
    j = 0
    While j <= MAX_COLUMNS And Trim(s2.Cells(1, j + 1).Value) <> ""
        j = j + 1
    Wend
    ' Maximum of the number of columns in header of the two sheets.
    If j > Sheet_MAX_COLUMNS Then
        Sheet_MAX_COLUMNS = j
    End If
    
    ' Column at which this macro will mark that the column is different.
    Sheet_Mark_Diff_Column_Num = Sheet_MAX_COLUMNS + 1
    ' Clearing the values in the above column on the two sheets.
    If Total_Num_Rows_Sheet1 > 0 Then
       s1.Activate
       s1.Range(Cells(1, Sheet_Mark_Diff_Column_Num), Cells(Total_Num_Rows_Sheet1, Sheet_Mark_Diff_Column_Num)).Value = ""
    End If
    If Total_Num_Rows_Sheet2 Then
       s2.Activate
       s2.Range(Cells(1, Sheet_Mark_Diff_Column_Num), Cells(Total_Num_Rows_Sheet2, Sheet_Mark_Diff_Column_Num)).Value = ""
    End If
    
    ' Ask user for the number of columns or rows to compare (User might want to compare only a range).
    If user_input_parameter = "Y" Then
        user_input = InputBox("Do you want to mark the column next to last column as 'Y' for rows which don't match?", "Mark the non-matching rows ...", "N")
        If user_input = "Y" Or user_input = "y" Or user_input = "N" Or user_input = "n" Then
            ' Mark the flag to true.
            If user_input = "Y" Or user_input = "y" Then
                Sheet_Mark_Diff_Column_Flag = True
            End If
        Else
            MsgBox "Invalid option. Macro will not mark the column next to last column as 'Y' for non-matching rows.", vbOKOnly + vbInformation, "Macro"
        End If
        
        user_input = InputBox("Starting column for comparison:", "Starting column for comparison ...", Sheet_START_COLUMN)
        If user_input <> "" And IsNumeric(user_input) Then
            ' User value should be greater than the default value and less than max column value.
            If user_input > Sheet_START_COLUMN And user_input <= Sheet_MAX_COLUMNS Then
                Sheet_START_COLUMN = user_input
            End If
        Else
            MsgBox "Invalid number. Using default starting column for comparison (" & Sheet_START_COLUMN & ")for comparison.", vbOKOnly + vbInformation, "Macro"
        End If
        
        user_input = InputBox("End column for comparison :", "End column for comparison ...", Sheet_MAX_COLUMNS)
        If user_input <> "" And IsNumeric(user_input) Then
            ' User value should be between start column and end column.
            If user_input < Sheet_MAX_COLUMNS And user_input >= Sheet_START_COLUMN Then
                Sheet_MAX_COLUMNS = user_input
            End If
        Else
            MsgBox "Invalid number. Using default number of columns (" & Sheet_MAX_COLUMNS & ") for comparison.", vbOKOnly + vbInformation, "Macro"
        End If
        
        user_input = InputBox("Max Number of Rows to compare :", "Max Number of Rows ...", Sheet_MAX_ROWS)
        If user_input <> "" And IsNumeric(user_input) Then
            ' Use Less of user value of default Max. Assuming start comparison row is 1.
            If user_input <= MAX_ROWS Then
                Sheet_MAX_ROWS = user_input
            End If
        Else
            MsgBox "Invalid number. Using default max number of rows (" & Sheet_MAX_ROWS & ")for comparison.", vbOKOnly + vbInformation, "Macro"
        End If
    End If
    ' End to user input logic.
    
    s1_i = sheet_START_ROW
    s2_i = sheet_START_ROW
    
    ' Here starts the comparison. ENJOY :-) !!
    'Start with the current row from the first sheet.
    While s1_i <= WorksheetFunction.Min(Total_Num_Rows_Sheet1, Sheet_MAX_ROWS)
        s2_i = last_match_sheet2 + 1
        b_match_found = False
        
        'Start with the next row to the last matched row in sheet2.
        While s2_i <= WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS) And b_match_found = False
            ' Start from the specified column till end.
            j = Sheet_START_COLUMN
            b_match_found = True
            
            ' Compare all the columns in the current row of the sheets.
            While j <= Sheet_MAX_COLUMNS And b_match_found = True
               If Trim(s1.Cells(s1_i, j).Value) <> Trim(s2.Cells(s2_i, j).Value) Then
                   b_match_found = False
               End If
               j = j + 1
            Wend
            
            If b_match_found = True Then
                ' If match is found for row in first sheet but not in the next to the last matched row in sheet2.
                If s2_i > (last_match_sheet2 + 1) Then
                    s2.Activate
                    s2.Range(Rows(last_match_sheet2 + 1), Rows(s2_i - 1)).Select
                    Call Mark_Bold_Color(40)
                    
                    If Sheet_Mark_Diff_Column_Flag Then
                       ' Mark the last column as Y because it is different.
                       s2.Range(Cells(last_match_sheet2 + 1, Sheet_Mark_Diff_Column_Num), Cells(s2_i - 1, Sheet_Mark_Diff_Column_Num)).Value = "Y"
                       s2.Range(Cells(last_match_sheet2 + 1, Sheet_Mark_Diff_Column_Num), Cells(s2_i - 1, Sheet_Mark_Diff_Column_Num)).Select
                       Call Mark_Bold_Color(35)
                    End If
                End If
                
                last_match_sheet1 = s1_i
                last_match_sheet2 = s2_i
            Else
                Overall_Match_Found = False
            End If
            
            s2_i = s2_i + 1
        Wend
        
        ' Row from first sheet does not match any in the second sheet.
        If b_match_found = False Then
            Overall_Match_Found = False
            s1.Activate
            s1.Range(Rows(s1_i), Rows(s1_i)).Select
            Call Mark_Bold_Color(40)
            
            If Sheet_Mark_Diff_Column_Flag Then
               ' Mark the last column as Y because it is different.
               s1.Cells(s1_i, Sheet_Mark_Diff_Column_Num).Value = "Y"
               s1.Cells(s1_i, Sheet_Mark_Diff_Column_Num).Select
               Call Mark_Bold_Color(35)
            End If
        End If
                
        s1_i = s1_i + 1
    Wend
    
    ' This will mark the new additions in the second sheet.
    If last_match_sheet2 < WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS) Then
        Overall_Match_Found = False
        s2.Activate
        s2.Range(Rows(last_match_sheet2 + 1), Rows(WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS))).Select
        Call Mark_Bold_Color(40)
        
        If Sheet_Mark_Diff_Column_Flag Then
           ' Mark the last column as Y because it is different.
           s2.Range(Cells(last_match_sheet2 + 1, Sheet_Mark_Diff_Column_Num), Cells(WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS), Sheet_Mark_Diff_Column_Num)).Value = "Y"
           s2.Range(Cells(last_match_sheet2 + 1, Sheet_Mark_Diff_Column_Num), Cells(WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS), Sheet_Mark_Diff_Column_Num)).Select
           Call Mark_Bold_Color(35)
        End If
    End If
    
    s2.Activate
    s2.Range("A1").Select
    s1.Activate
    s1.Range("A1").Select
    Current_sheet.Activate
    Current_sheet.Range("A1").Select
    
    ' Show the final comparison results whether sheets match or not.
    Final_Message = ""
    
    If Overall_Match_Found Then
       Final_Message = Final_Message & "Sheets are same."
    Else
       Final_Message = Final_Message & "Sheets are different." & Chr(10) & _
                       "Differences are marked in Bold and colored background."
    End If
    
    Final_Message = Final_Message & Chr(10) & Chr(10) & _
                    "Compared -" & Chr(10) & _
                    "    Sheet1 Rows      : " & sheet_START_ROW & "-" & WorksheetFunction.Min(Total_Num_Rows_Sheet1, Sheet_MAX_ROWS) & Chr(10) & _
                    "    Sheet2 Rows      : " & sheet_START_ROW & "-" & WorksheetFunction.Min(Total_Num_Rows_Sheet2, Sheet_MAX_ROWS) & Chr(10) & Chr(10) & _
                    "    Sheet1 Columns : " & Sheet_START_COLUMN & "-" & Sheet_MAX_COLUMNS & Chr(10) & _
                    "    Sheet2 Columns : " & Sheet_START_COLUMN & "-" & Sheet_MAX_COLUMNS

    If Sheet_Mark_Diff_Column_Flag And Not Overall_Match_Found Then
       Final_Message = Final_Message & Chr(10) & Chr(10) & _
                       "    Column number " & Sheet_Mark_Diff_Column_Num & " is marked 'Y' for non-matching rows."
    End If
    MsgBox Final_Message, vbOKOnly + vbInformation, "Macro Complete"
End Sub

' Subroutine to mark the current selection in bold and in color background.
Private Sub Mark_Bold_Color(ColorValue As Integer)
    Selection.Font.Bold = True
    
    With Selection.Interior
        .ColorIndex = ColorValue
        .Pattern = xlSolid
    End With
End Sub

' To Check if there is any filter condition set any of the columns of first row assuming it is the header row.
Private Sub CheckForFilterConditionsInHeaderRow(askUserForHeaderRow As Boolean, removeFilterOnColumns As Boolean)
    Const InputSplitTag = ","
    
    Dim iHeaderRow As Integer
    Dim iColumn As Integer
    Dim sColumnName As String
    Dim iHeaderRowString As String
    Dim MessageString As String
    Dim CurrentHeaderRowIsValid As Boolean
    
    Dim UserInputColumnNumbers As String
    Dim UserInputSingleColumnNumber As Variant
    Dim MaximumHeaderColumnNumber As Integer
    
    CurrentHeaderRowIsValid = False
    
    If (Not ActiveSheet.FilterMode) Then
        MsgBox "No filter on any of the Columns.", vbOKOnly + vbInformation, "Macro"
        Exit Sub
    End If
    
    iHeaderRow = 1
    MessageString = "Column Number ==> Column Header ==> Column Filter Criteria"
    
    If (askUserForHeaderRow) Then
        iHeaderRowString = InputBox("Enter the Row Number for Header Column:", "Header Column Number", iHeaderRow)
        
        If (IsEmpty(iHeaderRowString) Or IsNull(iHeaderRowString) Or (iHeaderRowString = "") Or (Not IsNumeric(iHeaderRowString))) Then
            Exit Sub
        End If
    Else
        iHeaderRowString = iHeaderRow
    End If
    
    iHeaderRow = Val(iHeaderRowString)
    
    iColumn = 1
    While (Trim(Cells(iHeaderRow, iColumn)) <> "")
        If (ActiveSheet.AutoFilter.Filters(iColumn).On) Then
            CurrentHeaderRowIsValid = True
            sColumnName = Left(Cells(1, iColumn).Address(False, False), 1 - (iColumn > 26))
            sColumnName = String(2 - Len(sColumnName), "_") & sColumnName
            MessageString = MessageString & Chr(10) & _
                            sColumnName & " (" & Format(iColumn, "##00") & _
                            ")" & " ==> " & _
                            Cells(iHeaderRow, iColumn).Value & " ==> " & _
                            FilterCriteria(Range(Cells(iHeaderRow, iColumn), Cells(iHeaderRow, iColumn)))
        End If
        
        iColumn = iColumn + 1
    Wend
    
    ' This should give the maximum column where header is present.
    MaximumHeaderColumnNumber = iColumn - 1
    
    If (Not CurrentHeaderRowIsValid) Then
        MsgBox "It appears that row " & iHeaderRow & " is not valid header row.", vbOKOnly + vbExclamation, "Macro"
        Exit Sub
    End If
    
    If ((CurrentHeaderRowIsValid) And (Not removeFilterOnColumns)) Then
        MsgBox MessageString, vbOKOnly + vbInformation, "Macro"
    Else
        ' Try removing filter for the columns input by user.
        MessageString = MessageString & Chr(10) & Chr(10) & _
                        "Please enter comma separated column numbers to remove filter from:"
                        
        UserInputColumnNumbers = InputBox(MessageString, "Remove Column Filters", "")

        MessageString = ""
        If (UserInputColumnNumbers <> "") Then
            For Each UserInputSingleColumnNumber In Split(UserInputColumnNumbers, InputSplitTag)
                MessageString = MessageString & Chr(10) & Trim(UserInputSingleColumnNumber) & " - "
                
                If (IsNumeric(UserInputSingleColumnNumber)) Then
                    iColumn = Val(UserInputSingleColumnNumber)
                Else
                    iColumn = 9999
                    MessageString = MessageString & "non numeric column number."
                End If
                
                If (iColumn <= MaximumHeaderColumnNumber) Then
                    sColumnName = Left(Cells(1, iColumn).Address(False, False), 1 - (iColumn > 26))
                    sColumnName = "Column " & sColumnName
                    
                    MessageString = MessageString & "(" & sColumnName & ") "
                    
                    If (ActiveSheet.AutoFilter.Filters(iColumn).On) Then
                        Selection.AutoFilter Field:=iColumn
                        
                        MessageString = MessageString & "filter removed"
                    Else
                        MessageString = MessageString & "no filter on this column"
                    End If
                ElseIf (iColumn <> 9999) Then
                    MessageString = MessageString & "too high column number or beyond header"
                End If
            Next
            
            MsgBox MessageString, vbOKOnly + vbInformation, "Remove Filter"
        End If
    End If
End Sub

' Return the criteria filter as string for a column.
Private Function FilterCriteria(Rng As Range) As String
    Dim Filter As String
    
    Filter = ""
    
    On Error GoTo Finish
    With Rng.Parent.AutoFilter
        If Intersect(Rng, .Range) Is Nothing Then GoTo Finish
        With .Filters(Rng.Column - .Range.Column + 1)
            If Not .On Then GoTo Finish
            Filter = "'" & .Criteria1 & "'"
            Select Case .Operator
                Case xlAnd
                    Filter = Filter & " AND '" & .Criteria2 & "'"
                Case xlOr
                    Filter = Filter & " OR '" & .Criteria2 & "'"
            End Select
        End With
    End With
    
Finish:
    FilterCriteria = Filter
End Function

' Work on the current sheet to add blank pattern and then select borders on the used range.
Private Sub ActiveSheetBlankPatternAndBorderOnUsedRange(ApplyBorder As Boolean)
    
    Cells.Select
    With Selection.Interior
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
    End With
    ActiveWindow.SmallScroll Down:=-6
    
    If (ApplyBorder = True) Then
        ActiveWorkbook.ActiveSheet.UsedRange.Select
        Selection.Borders(xlDiagonalDown).LineStyle = xlNone
        Selection.Borders(xlDiagonalUp).LineStyle = xlNone
        With Selection.Borders(xlEdgeLeft)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        With Selection.Borders(xlEdgeTop)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        With Selection.Borders(xlEdgeBottom)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        With Selection.Borders(xlEdgeRight)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        With Selection.Borders(xlInsideVertical)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
        With Selection.Borders(xlInsideHorizontal)
            .LineStyle = xlContinuous
            .Weight = xlThin
            .ColorIndex = xlAutomatic
        End With
    End If
    
    Range("A2:A2").Select
End Sub


' Read current file's data into current sheet with all columns as text
Private Sub ReOpenCurrentCSVFileWithAllColumnsAsText()
    Dim fileName As String
    Dim colDataTypesArr(1 To 1000) As Long
    Dim i As Long
    
    For i = 1 To UBound(colDataTypesArr)
        colDataTypesArr(i) = 2
    Next i

    fileName = Application.ActiveWorkbook.FullName
    If UCase(Right(Trim(fileName), 4)) <> ".CSV" Then
        Exit Sub
    End If
    
    ActiveWorkbook.Close False
    Workbooks.Add
    Application.WindowState = xlMaximized
    
    ActiveSheet.Cells.Clear
    ActiveSheet.Cells.NumberFormat = "@"
   
    Application.CutCopyMode = False
    With ActiveSheet.QueryTables.Add(Connection:= _
        "TEXT;" & fileName _
        , Destination:=Range("$A$1"))
        .Name = "1"
        .FieldNames = True
        .RowNumbers = False
        .FillAdjacentFormulas = False
        .PreserveFormatting = True
        .RefreshOnFileOpen = False
        .RefreshStyle = xlInsertDeleteCells
        .SavePassword = False
        .SaveData = True
        .RefreshPeriod = False
        .TextFilePromptOnRefresh = False
        .TextFilePlatform = 10000
        .TextFileStartRow = 1
        .TextFileParseType = xlDelimited
        .TextFileTextQualifier = xlTextQualifierDoubleQuote
        .TextFileConsecutiveDelimiter = False
        .TextFileTabDelimiter = False
        .TextFileSemicolonDelimiter = False
        .TextFileCommaDelimiter = True
        .TextFileSpaceDelimiter = False
        .TextFileColumnDataTypes = colDataTypesArr
        .TextFileTrailingMinusNumbers = True
        .Refresh BackgroundQuery:=False
    End With
End Sub


