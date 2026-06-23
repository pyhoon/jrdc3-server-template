B4J=true
Group=Handlers
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
'Handler class
Sub Class_Globals

End Sub

Public Sub Initialize

End Sub

Sub Handle (req As ServletRequest, resp As ServletResponse)
	resp.ContentType = "text/html"
	Dim sb As StringBuilder
	sb.Initialize
	If Main.RequestLog.IsInitialized = False Or Main.RequestLog.Size = 0 Then
		sb.Append("<div class=""log-empty"">No requests yet.</div>")
	Else
		Dim DF As String = DateTime.DateFormat
		Dim TF As String = DateTime.TimeFormat
		DateTime.DateFormat = "yyyy-MM-dd"
		DateTime.TimeFormat = "HH:mm:ss"
		For i = Main.RequestLog.Size - 1 To 0 Step -1
			Dim entry As LogEntry = Main.RequestLog.Get(i)
			sb.Append($"<div class="log-entry"><span class="log-time">$DateTime{entry.Ticks}</span><span class="log-method" data-method="${entry.Method}">${entry.Method}</span><span class="log-uri">${entry.URI}</span><span class="log-client">${entry.Client}</span><span class="log-duration">${entry.Duration}</span></div>"$)
		Next
		DateTime.DateFormat = DF
		DateTime.TimeFormat = TF
	End If
	resp.Write(sb.ToString)
End Sub