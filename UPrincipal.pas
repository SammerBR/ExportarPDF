unit UPrincipal;

interface

uses
  System.SysUtils, System.Classes, Printers, SynPDF, Vcl.Graphics,
  QuickRpt, QRCtrls;

type
  TExportarPDF = class(TComponent)
  private
    FNomePDF: String;
    FCaminhoQRP: String;
    procedure SetCaminhoQRP(const Value: String);
    procedure SetNomePDF(const Value: String);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure GerarPDF;
  published
    { Published declarations }
    property CaminhoQRP : String read FCaminhoQRP write SetCaminhoQRP;
    property NomePDF : String read FNomePDF write SetNomePDF;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('QuickReport', [TExportarPDF]);
end;

{ TExportarPDF }

procedure TExportarPDF.GerarPDF;
var
  oPDF: TPDFDocument;
  oMetaDados: TMetafile;
  oPosicionamento: TPDFCanvasRenderMetaFileTextPositioning;
  nPagina: integer;
  Relatorio : TQuickRep;
begin
  if CaminhoQRP = EmptyStr then
    raise Exception.Create('Caminho do arquivo .qrp em branco, Favor preencher!');

  if NomePDF = EmptyStr then
    raise Exception.Create('Nome do arquivo .pdf em branco, Favor preencher!');

  Relatorio := TQuickRep.Create(self);
  Relatorio.Prepare;
  Relatorio.QRPrinter.Load(CaminhoQRP);
  try
    oPDF := TPDFDocument.Create(True, 0, False, nil);

    oMetaDados := nil;
    try
      oPDF.DefaultPaperSize := psA4;
//      oPosicionamento := tpKerningFromAveragePosition;
      oPosicionamento := tpExactTextCharacterPositining;
      oPDF.Root.PageLayout := plOneColumn;

      if Relatorio.Page.Orientation = poLandscape then
      begin
        oPDF.DefaultPageLandscape := True;
      end;

      for nPagina := 1 to Relatorio.QRPrinter.PageCount do
      begin
        oPDF.AddPage;
        oMetaDados := Relatorio.QRPrinter.PageList.GetPage(nPagina);
        oPDF.Canvas.RenderMetaFile(oMetaDados, 1, 0, 0, 0, oPosicionamento);
        oMetaDados := nil;
      end;

      oPDF.SaveToFile(NomePDF);
    finally     
      oMetaDados.Free;
      oPDF.Free;
    end;
  finally
    FreeAndNil(Relatorio);
  end;
end;

procedure TExportarPDF.SetCaminhoQRP(const Value: String);
begin
  FCaminhoQRP := Value;
end;

procedure TExportarPDF.SetNomePDF(const Value: String);
begin
  FNomePDF := Value;
end;

end.
