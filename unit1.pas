unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Grids, fpjson, jsonparser, fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  CellColors: array of TColor;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if timer1.Enabled then
  begin
    timer1.Enabled:=false;
    edit1.Enabled:=true;
    Button1.Caption:='Connect';
    StringGrid1.RowCount:=1;
  end else begin
    timer1.Enabled:=true;
    edit1.Enabled:=false;
    Button1.Caption:='Disconnect';

  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure JSONParseOHMType( JSONData :TJSONData; OHMType :string );
var
  SensorName, SensorValue, SensorUnit: String;
  JSONItem : TJSONData;
  I: Integer;
begin

    Form1.StringGrid1.RowCount:= Form1.StringGrid1.RowCount+1;
    Form1.StringGrid1.Cells[0,Form1.StringGrid1.RowCount-1]:='<<< '+OHMType+' >>>';

    for I:=0 to JSONData.Count-1 do
    begin
        JSONItem:= JSONData.Items[I];
        if (JSONItem.Count > 0) AND (JSONItem.Items[1].AsString = OHMType) then
        begin
             SensorName:=JSONItem.Items[2].asString;
             SensorValue:= IntToStr(round(JSONItem.Items[3].AsFloat));
             SensorUnit:=JSONItem.Items[4].asString;

             Form1.StringGrid1.RowCount:= Form1.StringGrid1.RowCount+1;
             Form1.StringGrid1.Cells[0,Form1.StringGrid1.RowCount-1]:=SensorName;
             Form1.StringGrid1.Cells[1,Form1.StringGrid1.RowCount-1]:=SensorValue + ' ' + SensorUnit;

             //CellColors[I]:=Form1.StringGrid1.Font.Color;
             CellColors[I]:=clGray;

        end;
    end;

    JSONItem.Clear;
    SensorName:='';
    SensorValue:='';
    SensorUnit:='';
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (ACol=1) and (ARow>1) then
  begin
    // Fill rectangle with colour
    // Next, draw the text in the rectangle
    if ( CellColors[ARow] = clGray ) then
    begin
         StringGrid1.Canvas.Font.Color := clBlack;
    end else begin
         StringGrid1.Canvas.Font.Color := CellColors[ARow];
    end;
    StringGrid1.Canvas.Font.Style := [fsBold];
    // Make the rectangle where the text will be displayed a bit smaller than the cell
    // so the text is not "glued" to the grid lines
    StringGrid1.Canvas.TextOut(aRect.Left+2, aRect.Top+2, StringGrid1.Cells[ACol, ARow])
  end;

  if ( Pos ('<<<', StringGrid1.Cells[ACol, ARow] ) > 0 ) then
  begin
    StringGrid1.Canvas.Font.Color := clNavy;
    StringGrid1.Canvas.Font.Style := [fsBold];
    StringGrid1.Canvas.TextOut(aRect.Left+2, aRect.Top+2, StringGrid1.Cells[ACol, ARow]);

  end;

  if ( Pos ('Core', StringGrid1.Cells[ACol, ARow] ) > 0 ) then
  begin
    CellColors[ARow]:= clRed;
    StringGrid1.Canvas.Font.Color := clMaroon;
    StringGrid1.Canvas.TextOut(aRect.Left+2, aRect.Top+3, StringGrid1.Cells[ACol, ARow]);
  end;

  if ( Pos ('Memory', StringGrid1.Cells[ACol, ARow] ) > 0 ) then
  begin
    CellColors[ARow] := clGreen;
    StringGrid1.Canvas.Font.Color := clTeal;
    StringGrid1.Canvas.TextOut(aRect.Left+2, aRect.Top+2, StringGrid1.Cells[ACol, ARow]);
  end;

  if ( Pos ('Fan #', StringGrid1.Cells[ACol, ARow] ) > 0 ) then
  begin
    CellColors[ARow] := clBlue;
    StringGrid1.Canvas.Font.Color := TColor($F5A100);
    StringGrid1.Canvas.TextOut(aRect.Left+2, aRect.Top+2, StringGrid1.Cells[ACol, ARow]);
  end;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  JSONString : String;
  JSONData : TJSONData;
begin

    JSONString := TFPCustomHTTPClient.SimpleGet(Edit1.Text);
    JSONData:=GetJSON(JSONString);

    StringGrid1.RowCount:= 1;
    StringGrid1.Cols[1];

    SetLength(CellColors, JSONData.Count);

    JSONParseOHMType(JSONData, 'Temperature');
    JSONParseOHMType(JSONData, 'Fan');
    JSONParseOHMType(JSONData, 'Load');

    JSONString:='';
    JSONData.Clear;

end;

end.

