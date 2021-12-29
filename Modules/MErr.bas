Attribute VB_Name = "MErr"
Option Explicit
Private Const FORMAT_MESSAGE_MAX_WIDTH_MASK  As Long = &HFF&
Private Const FORMAT_MESSAGE_ALLOCATE_BUFFER As Long = &H100
Private Const FORMAT_MESSAGE_IGNORE_INSERTS  As Long = &H200
Private Const FORMAT_MESSAGE_FROM_STRING     As Long = &H400
Private Const FORMAT_MESSAGE_FROM_HMODULE    As Long = &H800
Private Const FORMAT_MESSAGE_FROM_SYSTEM     As Long = &H1000
Private Const FORMAT_MESSAGE_ARGUMENT_ARRAY  As Long = &H2000
#If VBA7 Then
    Private Declare PtrSafe Function GetLastError Lib "kernel32" () As Long
    Private Declare PtrSafe Function FormatMessageW Lib "kernel32.dll" (ByVal dwFlags As Long, ByRef lpSource As Any, ByVal dwMessageId As Long, ByVal dwLanguageId As Long, ByVal lpBuffer As LongPtr, ByVal nSize As Long, ByRef Arguments As Long) As Long
#Else
    Public Enum LongPtr
        [_]
    End Enum
    Private Declare Function GetLastError Lib "kernel32" () As Long
    Private Declare Function FormatMessageW Lib "kernel32.dll" (ByVal dwFlags As Long, ByRef lpSource As Any, ByVal dwMessageId As Long, ByVal dwLanguageId As Long, ByVal lpBuffer As LongPtr, ByVal nSize As Long, ByRef Arguments As Long) As Long
#End If
Public ErrLog As String

'OK, bei Inline-Fehlern die z.B. von WinAPI-Funktionen �ber HResult zur�ckgegeben werden, ist das hier noch etwas Schwach
'OK f�r Fehlernummer 4 verschiedene M�glichkeiten
'* Err.Number
'* Err.LastDllError
'* GetLastError
'* HResult
Public Function MessError(ClsName As String, FncName As String, _
                          Optional AddInfo As String = "", _
                          Optional WinApiErr As Long = 0, _
                          Optional bLoud As Boolean = True, _
                          Optional bErrLog As Boolean = True, _
                          Optional vbDecor As VbMsgBoxStyle = vbOKOnly) As VbMsgBoxResult ' vbOKOnly Or vbCritical
    If bLoud Then

        Dim sErr As String:  sErr = ClsName & "::" & FncName
        If Len(AddInfo) Then sErr = sErr & vbCrLf & "Info:   " & AddInfo
        If Err.Number Then sErr = sErr & vbCrLf & "ErrNr " & Err.Number & ": " & Err.Description
        If Err.LastDllError Then sErr = sErr & vbCrLf & "DllErrNr: " & Err.LastDllError & " " & Err.Description
        Dim LastError As Long: LastError = GetLastError
        If LastError Then sErr = sErr & vbCrLf & "LastError " & LastError & ": " & WinApiError_ToStr(LastError)
        If WinApiErr Then sErr = sErr & vbCrLf & "WinApiErr " & WinApiErr & ": " & WinApiError_ToStr(WinApiErr)
        
        MessError = MsgBox(sErr, vbDecor)
    End If
    If bErrLog Then
        ErrLog = ErrLog & vbCrLf & Now & " " & sErr
    End If
End Function

Public Function MessErrorRetry(ClsName As String, FncName As String, _
                               Optional AddInfo As String = "", _
                               Optional WinApiErr As Long = 0, _
                               Optional bErrLog As Boolean = True) As VbMsgBoxResult
    MessErrorRetry = MessError(ClsName, FncName, AddInfo, True, bErrLog, vbRetryCancel)
End Function

Public Function WinApiError_ToStr(ByVal MessageID As Long) As String
    'MessageID e.g. hResult
    Dim l As Long:   l = 256
    Dim s As String: s = Space(l)
    l = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_IGNORE_INSERTS, 0&, MessageID, 0&, StrPtr(s), l, ByVal 0&)
    If l Then WinApiError_ToStr = Left$(s, l)
End Function

