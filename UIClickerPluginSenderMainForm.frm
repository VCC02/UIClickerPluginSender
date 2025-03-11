object frmPluginSenderMain: TfrmPluginSenderMain
  Left = 373
  Height = 320
  Top = 185
  Width = 627
  Caption = 'UIClicker Plugin Sender'
  ClientHeight = 320
  ClientWidth = 627
  Constraints.MinHeight = 320
  Constraints.MinWidth = 627
  LCLVersion = '8.4'
  OnClose = FormClose
  OnCreate = FormCreate
  object lbeClickerClientPath: TLabeledEdit
    Left = 8
    Height = 23
    Hint = '$AppDir$ replacement is available.'
    Top = 32
    Width = 360
    EditLabel.Height = 15
    EditLabel.Width = 360
    EditLabel.Caption = 'ClickerClient Path'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    Text = '$AppDir$\..\UIClicker\ClickerClient\ClickerClient.dll'
  end
  object lbeServerConnection: TLabeledEdit
    Left = 488
    Height = 23
    Top = 32
    Width = 131
    EditLabel.Height = 15
    EditLabel.Width = 131
    EditLabel.Caption = 'ServerAddress:Port'
    TabOrder = 1
    Text = '127.0.0.1:5444'
    OnChange = lbeServerConnectionChange
  end
  object btnLoadClickerClient: TButton
    Left = 384
    Height = 25
    Top = 0
    Width = 75
    Caption = 'Load'
    TabOrder = 2
    OnClick = btnLoadClickerClientClick
  end
  object btnUnloadClickerClient: TButton
    Left = 384
    Height = 25
    Top = 30
    Width = 75
    Caption = 'Unload'
    Enabled = False
    TabOrder = 3
    OnClick = btnUnloadClickerClientClick
  end
  object memFilesToSend: TMemo
    Left = 8
    Height = 90
    Top = 80
    Width = 534
    Anchors = [akTop, akLeft, akRight]
    ScrollBars = ssBoth
    TabOrder = 4
    WordWrap = False
  end
  object lblFilesToSend: TLabel
    Left = 8
    Height = 15
    Top = 64
    Width = 68
    Caption = 'Files to send:'
  end
  object btnSend: TButton
    Left = 544
    Height = 25
    Top = 144
    Width = 75
    Anchors = [akTop, akRight]
    Caption = 'Send'
    Enabled = False
    TabOrder = 5
    OnClick = btnSendClick
  end
  object memLog: TMemo
    Left = 8
    Height = 104
    Top = 208
    Width = 611
    Anchors = [akTop, akLeft, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object lblLog: TLabel
    Left = 8
    Height = 15
    Top = 192
    Width = 20
    Caption = 'Log'
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrStartupTimer
    Left = 415
    Top = 230
  end
end
