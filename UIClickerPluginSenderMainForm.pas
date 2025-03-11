{
    Copyright (C) 2025 VCC
    creation date: 10 Mar 2025
    initial release date: 11 Mar 2025

    author: VCC
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}


unit UIClickerPluginSenderMainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfrmPluginSenderMain }

  TfrmPluginSenderMain = class(TForm)
    btnLoadClickerClient: TButton;
    btnUnloadClickerClient: TButton;
    btnSend: TButton;
    lblLog: TLabel;
    lblFilesToSend: TLabel;
    lbeClickerClientPath: TLabeledEdit;
    lbeServerConnection: TLabeledEdit;
    memFilesToSend: TMemo;
    memLog: TMemo;
    tmrStartup: TTimer;
    procedure btnLoadClickerClientClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnUnloadClickerClientClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lbeServerConnectionChange(Sender: TObject);
    procedure tmrStartupTimer(Sender: TObject);
  private
    FLoadClickerClientRes: Boolean;
    FTestServerAddress: string;
    FSkipSavingIni: Boolean;
    FAutoClose: Boolean;

    procedure AddToLog(s: string);
    procedure LoadSettingsFromIni;
    procedure SaveSettingsToIni;
  public

  end;

var
  frmPluginSenderMain: TfrmPluginSenderMain;

implementation

{$R *.frm}


uses
  DllUtils, ClickerClientIntf, IniFiles;

{ TfrmPluginSenderMain }


procedure TfrmPluginSenderMain.AddToLog(s: string);
begin
  memLog.Lines.Add(s);
end;


procedure TfrmPluginSenderMain.LoadSettingsFromIni;
var
  Ini: TMemIniFile;
  i, n: Integer;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + 'UIClickerPluginSender.ini');
  try
    Left := Ini.ReadInteger('Window', 'Left', Left);
    Top := Ini.ReadInteger('Window', 'Top', Top);
    Width := Ini.ReadInteger('Window', 'Width', Width);
    Height := Ini.ReadInteger('Window', 'Height', Height);

    lbeClickerClientPath.Text := Ini.ReadString('Settings', 'ClickerClientPath', lbeClickerClientPath.Text);
    lbeServerConnection.Text := Ini.ReadString('Settings', 'ServerConnection', lbeServerConnection.Text);

    n := Ini.ReadInteger('Settings', 'FileCount', 0);
    memFilesToSend.Clear;
    for i := 0 to n - 1 do
      memFilesToSend.Lines.Add(Ini.ReadString('Settings', 'File_' + IntToStr(i), ''));
  finally
    Ini.Free;
  end;
end;


procedure TfrmPluginSenderMain.SaveSettingsToIni;
var
  Ini: TMemIniFile;
  i, n: Integer;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + 'UIClickerPluginSender.ini');
  try
    Ini.WriteInteger('Window', 'Left', Left);
    Ini.WriteInteger('Window', 'Top', Top);
    Ini.WriteInteger('Window', 'Width', Width);
    Ini.WriteInteger('Window', 'Height', Height);

    Ini.WriteString('Settings', 'ClickerClientPath', lbeClickerClientPath.Text);
    Ini.WriteString('Settings', 'ServerConnection', lbeServerConnection.Text);

    n := memFilesToSend.Lines.Count;
    Ini.WriteInteger('Settings', 'FileCount', n);
    for i := 0 to n - 1 do
      Ini.WriteString('Settings', 'File_' + IntToStr(i), memFilesToSend.Lines.Strings[i]);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;


procedure TfrmPluginSenderMain.btnLoadClickerClientClick(Sender: TObject);
var
  TempTestServerAddress, Path: string;
begin
  Path := lbeClickerClientPath.Text;
  Path := StringReplace(Path, '$AppDir$', ExtractFileDir(ParamStr(0)), [rfReplaceAll]);

  FLoadClickerClientRes := LoadClickerClient(Path);
  if not FLoadClickerClientRes then
  begin
    MessageBoxFunction('Can''t load ClickerClient.dll', PChar(Application.Title), 0);
    Exit;
  end;

  TempTestServerAddress := 'http://' + FTestServerAddress + '/';
  InitClickerClient;
  SetServerAddress(@WideString(TempTestServerAddress)[1]);

  btnLoadClickerClient.Enabled := False;
  btnUnloadClickerClient.Enabled := True;
  btnSend.Enabled := True;
end;


procedure TfrmPluginSenderMain.btnSendClick(Sender: TObject);
var
  i: Integer;
  MemStream: TMemoryStream;
  FileName, Response: string;
  FileNameWS: WideString;
  ResLen: Integer;
begin
  for i := 0 to memFilesToSend.Lines.Count - 1 do
  begin
    FileName := memFilesToSend.Lines.Strings[i];

    MemStream := TMemoryStream.Create;
    try
      FileNameWS := WideString(ExtractFileName(FileName));
      SetLength(Response, CMaxSharedStringLength);

      MemStream.LoadFromFile(FileName);
      ResLen := SendMemPluginFileToServer(@FileNameWS[1], MemStream.Memory, MemStream.Size, @Response[1]);
      SetLength(Response, ResLen);

      AddToLog('File: "' + ExtractFileName(FileName) + '"  Response: ' + Response);
    finally
      MemStream.Free;
    end;
  end;
end;


procedure TfrmPluginSenderMain.btnUnloadClickerClientClick(Sender: TObject);
begin
  if FLoadClickerClientRes then
  begin
    try
      DoneClickerClient;
    finally
      UnLoadClickerClient;
    end;

    btnLoadClickerClient.Enabled := True;
    btnUnloadClickerClient.Enabled := False;
    btnSend.Enabled := False;
  end;
end;


procedure TfrmPluginSenderMain.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  try
    btnUnloadClickerClient.Click;
  except
  end;

  try
    if not FSkipSavingIni then
      SaveSettingsToIni;
  except
  end;
end;


procedure TfrmPluginSenderMain.FormCreate(Sender: TObject);
begin
  FSkipSavingIni := False;
  FTestServerAddress := lbeServerConnection.Text;
  tmrStartup.Enabled := True;
end;


procedure TfrmPluginSenderMain.lbeServerConnectionChange(Sender: TObject);
begin
  FTestServerAddress := lbeServerConnection.Text;
end;


procedure TfrmPluginSenderMain.tmrStartupTimer(Sender: TObject);
var
  i: Integer;
begin
  tmrStartup.Enabled := False;
  LoadSettingsFromIni;

  FAutoClose := False;

  i := 1;
  repeat
    if ParamStr(i) = '--SetServerConnection' then
    begin
      FAutoClose := True;
      lbeServerConnection.Text := ParamStr(i + 1);
      Inc(i);
    end;

    if ParamStr(i) = '--ClickerClientPath' then
    begin
      FAutoClose := True;
      lbeClickerClientPath.Text := ParamStr(i + 1);
      Inc(i);
    end;

    if ParamStr(i) = '--SkipSavingIni' then
    begin
      FAutoClose := True;
      FSkipSavingIni := True;

      if (ParamStr(i + 1) = 'Yes') or (ParamStr(i + 1) = 'True') then
        Inc(i);
    end;

    if ParamStr(i) = '--ClearCurrentListOfFiles' then
    begin
      FAutoClose := True;
      memFilesToSend.Clear;

      if (ParamStr(i + 1) = 'Yes') or (ParamStr(i + 1) = 'True') then
        Inc(i);
    end;

    if ParamStr(i) = '--AddFileToList' then
    begin
      FAutoClose := True;
      memFilesToSend.Lines.Add(ParamStr(i + 1));
    end;

    if ParamStr(i) = '--AutoClose' then
    begin
      if (ParamStr(i + 1) = 'No') or (ParamStr(i + 1) = 'False') then
      begin
        FAutoClose := False;
        Inc(i);
      end;
    end;
  until i >= ParamCount;

  if FAutoClose then
  begin
    try
      btnLoadClickerClient.Click;
    except
      on E: Exception do
        AddToLog('Ex: "' + E.Message + '" on loading ClickerClient.');
    end;

    try
      btnSend.Click;
    except
      on E: Exception do
        AddToLog('Ex: "' + E.Message + '" on sending files.');
    end;

    try
      btnUnloadClickerClient.Click;
    except
      on E: Exception do
        AddToLog('Ex: "' + E.Message + '" on unloading ClickerClient.');
    end;

    Close;
  end;
end;

end.

