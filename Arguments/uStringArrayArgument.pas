unit uStringArrayArgument;

interface

uses
  uTypes,
  uCustomArgument;

type
  TStringArrayArgument = class(TCustomArgument)
  private
    FValues: TArrayOfString;
    FSeparator: string;
    FDefaultValues: TArrayOfString;
    procedure SetSeparator(const Value: string);
    function GetValues: TArrayOfString;
    procedure SetDefaultValues(const Value: TArrayOfString);
  protected
    function GetSyntax: string; override;
  public
    constructor Create;
    procedure SetValueFromString(const AValue: string); override;

    property Separator: string read FSeparator write SetSeparator;

    property DefaultValues: TArrayOfString read FDefaultValues write SetDefaultValues;
    property Values: TArrayOfString read GetValues;
  end;

implementation

uses
  uStrings;

{ TStringArrayArgument }

constructor TStringArrayArgument.Create;
begin
  inherited;

  FSeparator := ';';
end;

function TStringArrayArgument.GetSyntax: string;
begin
  Result := 'value1' + Separator + 'value2' + Separator + 'value3...';
end;

function TStringArrayArgument.GetValues: TArrayOfString;
begin
  Used := True;
  Result := FValues;
end;

procedure TStringArrayArgument.SetDefaultValues(const Value: TArrayOfString);
begin
  FDefaultValues := Value;
end;

procedure TStringArrayArgument.SetSeparator(const Value: string);
begin
  FSeparator := Value;
end;

procedure TStringArrayArgument.SetValueFromString(const AValue: string);
begin
  inherited;

  FValues := SplitStringEx(AValue, Separator);
end;

end.
