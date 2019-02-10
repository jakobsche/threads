unit EvMsg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { IMessageReceiver }

{ Interface for an object, that has to receive messages from a
  TMessageGenerator instance }
  IMessageReceiver = interface
    procedure GenerateEvents; {is called by a TMessageGenerator instance to
      send a message to an object with this Interface, calls, for example,
      the method DispatchMessage or DispatchMessageStr of that object}
  end;

  { TMessageGenerator }

  TMessageGenerator = class(TThread)
  private
    NewReceiver, DestroyedReceiver: IMessageReceiver;
    function GetReceiverList: TList;
  private
    FReceiverList: TList;
    function GetReceiverCount: Integer;
    function GetReceivers(I: Integer): IMessageReceiver;
    property ReceiverList: TList read GetReceiverList;
  protected
    procedure Execute; override;
    property ReceiverCount: Integer read GetReceiverCount;
    property Receivers[I: Integer]: IMessageReceiver read GetReceivers;
  public
    function AddReceiver(AReceiver: IMessageReceiver): Boolean;
    function RemoveReceiver(AReceiver: IMessageReceiver): Boolean;
    destructor Destroy; override;
  end;

implementation

{ TMessageGenerator }

function TMessageGenerator.GetReceiverList: TList;
begin
  if not Assigned(FReceiverList) then FReceiverList := TList.Create;
  Result := FReceiverList
end;

function TMessageGenerator.GetReceiverCount: Integer;
begin
  if Assigned(FReceiverList) then Result := FReceiverList.Count
  else Result := 0
end;

function TMessageGenerator.GetReceivers(I: Integer): IMessageReceiver;
begin
  Result := IMessageReceiver(ReceiverList[I])
end;

procedure TMessageGenerator.Execute;
var
  I: Integer;
begin
  while not Terminated do begin
    if Suspended then Continue;
    if NewReceiver <> nil then begin
      ReceiverList.Add(NewReceiver);
      NewReceiver := nil
    end;
    if DestroyedReceiver <> nil then begin
      ReceiverList.Remove(DestroyedReceiver);
      DestroyedReceiver := nil;
    end;
    I := 0;
    while I < ReceiverCount do begin
      if Suspended then Continue;
      if Terminated then Exit;
      Synchronize(@Receivers[I].GenerateEvents);
      Inc(I)
    end;
  end;
end;

function TMessageGenerator.AddReceiver(AReceiver: IMessageReceiver): Boolean;
begin
  if Suspended then begin
    ReceiverList.Add(AReceiver);
    Result := True
  end
  else
    if NewReceiver = nil then begin
      NewReceiver := AReceiver;
      Result := True
    end
    else Result := False
end;

function TMessageGenerator.RemoveReceiver(AReceiver: IMessageReceiver): Boolean;
begin
  if Suspended then begin
    ReceiverList.Remove(AReceiver);
    Result := True
  end
  else
    if DestroyedReceiver = nil then begin
      DestroyedReceiver := AReceiver;
      Result := True
    end
    else Result := False;
end;

destructor TMessageGenerator.Destroy;
begin
  Terminate;
  FReceiverList.Free;
  inherited Destroy;
end;

end.

