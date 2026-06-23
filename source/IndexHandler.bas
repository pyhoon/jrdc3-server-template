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
	Main.AddLog("GET", req.RequestURI, req.RemoteAddress, "-")
	Log($"Loading ${req.FullRequestURI} ..."$)
	resp.ContentType = "text/html"
	If req.RequestURI = "/test" Then
		If TestConnection Then
			resp.Write($"<span style="color: lime">Connection successful.</span>"$)
		Else
			resp.Write($"<span style="color: red">Error fetching connection.</span>"$)
		End If
	Else
		resp.Write(IndexPage)
	End If
End Sub

Sub TestConnection As Boolean
	Try
		Dim Con As SQL = Main.rdcConnector1.GetConnection
		Con.Close
		#If DBF
		Dim Con As SQL = Main.rdcConnector1.GetConnection2
		Con.Close
		#End If
		Return True
	Catch
		Log(LastException.Message)
		Return False
	End Try
End Sub

Sub IndexPage As String
	DateTime.DateFormat = "dd/MM/yyyy"
	DateTime.TimeFormat = "hh:mm:ss a"
	Dim Html As String = $"<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>jRDC3 Server</title>
	<link rel="icon" type="image/png" href="img/favicon-32x32.png" sizes="32x32" />
	<link href="https://fonts.googleapis.com/css?family=Karla:400" rel="stylesheet" type="text/css">
    <script src="/js/htmx.min.js"></script>
	<style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #0c1445 0%, #1a237e 50%, #0d47a1 100%);
            overflow: hidden;
            /* font-family: 'Segoe UI', Arial, sans-serif; */
			font-weight: 100;
			font-family: 'Karla';
        }

        .container {
            position: relative;
            width: 800px;
            height: 600px;
        }

        /* jRDC3 Title Text */
        .jrdc3-title {
            position: absolute;
            top: 4%;
            left: 50%;
            color: #ffffff;
            font-size: 46px;
            font-weight: 800;
            letter-spacing: 6px;
            text-shadow: 0 0 10px rgba(0, 220, 255, 0.8),
                         0 0 20px rgba(0, 150, 255, 0.6),
                         0 0 40px rgba(0, 100, 255, 0.4);
            z-index: 30;
            animation: titleFloat 4s ease-in-out infinite, titleGlow 3s ease-in-out infinite;
        }

        @keyframes titleFloat {
            0%, 100% { transform: translateX(-50%) translateY(0px); }
            50% { transform: translateX(-50%) translateY(-8px); }
        }

        @keyframes titleGlow {
            0%, 100% {
                text-shadow: 0 0 10px rgba(0, 220, 255, 0.8),
                             0 0 20px rgba(0, 150, 255, 0.6);
            }
            50% {
                text-shadow: 0 0 15px rgba(0, 220, 255, 1),
                             0 0 30px rgba(0, 150, 255, 0.9),
                             0 0 50px rgba(0, 100, 255, 0.6);
            }
        }

        /* Central Server Node */
        .server-node {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 120px;
            height: 120px;
            background: radial-gradient(circle, rgba(100, 220, 255, 0.8) 0%, rgba(0, 150, 255, 0.6) 40%, rgba(0, 100, 200, 0.4) 100%);
            border-radius: 50%;
            box-shadow: 0 0 60px rgba(100, 220, 255, 0.8),
                        0 0 100px rgba(0, 150, 255, 0.6),
                        inset 0 0 30px rgba(255, 255, 255, 0.3);
            animation: pulse 2s ease-in-out infinite;
            z-index: 10;
        }

        .server-node::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 60px;
            height: 60px;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.9) 0%, rgba(200, 240, 255, 0.7) 100%);
            border-radius: 50%;
            box-shadow: 0 0 20px rgba(255, 255, 255, 0.8);
        }

        /* Connection Lines */
        .connection {
            position: absolute;
            top: 50%;
            left: 50%;
            height: 3px;
            background: linear-gradient(90deg, rgba(100, 220, 255, 0.2), rgba(100, 220, 255, 0.8), rgba(100, 220, 255, 0.2));
            transform-origin: left center;
            box-shadow: 0 0 10px rgba(100, 220, 255, 0.6);
            z-index: 5;
        }

        .connection::after {
            content: '';
            position: absolute;
            right: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 8px;
            height: 8px;
            background: rgba(100, 220, 255, 1);
            border-radius: 50%;
            box-shadow: 0 0 15px rgba(100, 220, 255, 1);
            animation: dataFlow 2s ease-in-out infinite;
        }

        .connection-1 {
            width: 290px;
            transform: rotate(-152deg);
            animation: connectionPulse1 3s ease-in-out infinite;
        }

        .connection-2 {
            width: 290px;
            transform: rotate(-28deg);
            animation: connectionPulse2 3s ease-in-out infinite 0.5s;
        }

        .connection-3 {
            width: 130px;
            transform: rotate(90deg);
            animation: connectionPulse3 3s ease-in-out infinite 1s;
        }

        /* Device Nodes */
        .device {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(100, 220, 255, 0.4);
            border-radius: 15px;
            box-shadow: 0 0 30px rgba(100, 220, 255, 0.3),
                        inset 0 0 20px rgba(100, 220, 255, 0.1);
            animation: deviceFloat 4s ease-in-out infinite;
            z-index: 15;
        }

        .device-1 {
            top: 12%;
            left: 8%;
            width: 80px;
            height: 140px;
            animation-delay: 0s;
        }

        .device-2 {
            top: 12%;
            right: 8%;
            width: 80px;
            height: 140px;
            animation-delay: 1.33s;
        }

        .device-3 {
            bottom: 10%;
            left: 50%;
            margin-left: -80px;
            width: 160px;
            height: 110px;
            animation-delay: 2.66s;
        }

        .device::before {
            content: '';
            position: absolute;
            top: 10px;
            left: 10px;
            right: 10px;
            bottom: 10px;
            background: linear-gradient(135deg, rgba(100, 220, 255, 0.2) 0%, rgba(0, 150, 255, 0.1) 100%);
            border-radius: 8px;
            overflow: hidden;
        }

        .device::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 40px;
            height: 40px;
            background: radial-gradient(circle, rgba(100, 220, 255, 0.6) 0%, transparent 70%);
            border-radius: 50%;
            animation: devicePulse 2s ease-in-out infinite;
        }

        .device-label {
            position: absolute;
            bottom: -32px;
            left: 50%;
            transform: translateX(-50%);
            color: rgba(255, 255, 255, 0.95);
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-shadow: 0 0 10px rgba(100, 220, 255, 0.8),
                         0 0 20px rgba(0, 150, 255, 0.6);
            white-space: nowrap;
            z-index: 20;
            animation: labelGlow 2s ease-in-out infinite;
        }

        /* ===== INFO PANEL ===== */
        .info-panel {
            position: absolute;
            bottom: 4%;
            right: 3%;
            background: rgba(255, 255, 255, 0.07);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(100, 220, 255, 0.25);
            border-radius: 12px;
            padding: 16px 22px;
            z-index: 25;
            min-width: 240px;
            max-width: 320px;
            box-shadow: 0 0 25px rgba(0, 100, 200, 0.15),
                        inset 0 0 15px rgba(100, 220, 255, 0.05);
            animation: infoPanelFadeIn 1.5s ease-out forwards, infoPanelGlow 4s ease-in-out infinite 1.5s;
            opacity: 0;
        }

        .info-panel::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, transparent, rgba(100, 220, 255, 0.6), transparent);
            border-radius: 12px 12px 0 0;
        }

        .info-panel .info-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(100, 220, 255, 0.15);
        }

        .info-panel .status-dot {
            width: 8px;
            height: 8px;
            background: #00e676;
            border-radius: 50%;
            box-shadow: 0 0 8px rgba(0, 230, 118, 0.8);
            animation: statusBlink 2s ease-in-out infinite;
        }

        .info-panel .info-header span {
            color: rgba(255, 255, 255, 0.7);
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .info-panel .info-row {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            padding: 4px 0;
            font-size: 12px;
            line-height: 1.8;
        }

        .info-panel .info-label {
            color: rgba(180, 210, 240, 0.7);
            font-weight: 400;
            white-space: nowrap;
        }

        .info-panel .info-value {
            color: #ffffff;
            font-weight: 600;
            text-align: right;
            text-shadow: 0 0 6px rgba(100, 220, 255, 0.4);
        }

        .info-panel .info-connection {
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid rgba(100, 220, 255, 0.1);
            font-size: 11px;
            color: rgba(180, 220, 255, 0.6);
            line-height: 1.6;
        }

        .info-panel .info-timestamp {
            margin-top: 8px;
            font-size: 10px;
            color: rgba(150, 190, 230, 0.45);
            text-align: right;
        }

        @keyframes infoPanelFadeIn {
            0% {
                opacity: 0;
                transform: translateY(15px);
            }
            100% {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes infoPanelGlow {
            0%, 100% {
                box-shadow: 0 0 25px rgba(0, 100, 200, 0.15),
                            inset 0 0 15px rgba(100, 220, 255, 0.05);
                border-color: rgba(100, 220, 255, 0.25);
            }
            50% {
                box-shadow: 0 0 35px rgba(0, 100, 200, 0.25),
                            inset 0 0 20px rgba(100, 220, 255, 0.08);
                border-color: rgba(100, 220, 255, 0.4);
            }
        }

        @keyframes statusBlink {
            0%, 100% {
                opacity: 1;
                box-shadow: 0 0 8px rgba(0, 230, 118, 0.8);
            }
            50% {
                opacity: 0.6;
                box-shadow: 0 0 4px rgba(0, 230, 118, 0.4);
            }
        }

        /* Data Particles */
        .particle {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 4px;
            height: 4px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 50%;
            box-shadow: 0 0 10px rgba(100, 220, 255, 0.9);
            animation: particleMove 3s linear infinite;
            z-index: 12;
        }

        .particle-1 { animation-delay: 0s; }
        .particle-2 { animation-delay: 1s; }
        .particle-3 { animation-delay: 2s; }

        /* Animations */
        @keyframes pulse {
            0%, 100% {
                transform: translate(-50%, -50%) scale(1);
                box-shadow: 0 0 60px rgba(100, 220, 255, 0.8),
                            0 0 100px rgba(0, 150, 255, 0.6);
            }
            50% {
                transform: translate(-50%, -50%) scale(1.1);
                box-shadow: 0 0 80px rgba(100, 220, 255, 1),
                            0 0 120px rgba(0, 150, 255, 0.8);
            }
        }

        @keyframes connectionPulse1 { 0%, 100% { opacity: 0.6; } 50% { opacity: 1; } }
        @keyframes connectionPulse2 { 0%, 100% { opacity: 0.6; } 50% { opacity: 1; } }
        @keyframes connectionPulse3 { 0%, 100% { opacity: 0.6; } 50% { opacity: 1; } }

        @keyframes dataFlow {
            0%, 100% { opacity: 0; transform: translateY(-50%) scale(0.5); }
            50% { opacity: 1; transform: translateY(-50%) scale(1.2); }
        }

        @keyframes deviceFloat {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }

        @keyframes devicePulse {
            0%, 100% { opacity: 0.5; transform: translate(-50%, -50%) scale(1); }
            50% { opacity: 1; transform: translate(-50%, -50%) scale(1.3); }
        }

        @keyframes labelGlow {
            0%, 100% {
                opacity: 0.8;
                text-shadow: 0 0 10px rgba(100, 220, 255, 0.8), 0 0 20px rgba(0, 150, 255, 0.6);
            }
            50% {
                opacity: 1;
                text-shadow: 0 0 15px rgba(100, 220, 255, 1), 0 0 30px rgba(0, 150, 255, 0.8), 0 0 40px rgba(0, 150, 255, 0.6);
            }
        }

        @keyframes particleMove {
            0% { transform: translate(0, 0); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translate(var(--tx), var(--ty)); opacity: 0; }
        }

        /* Background Glow Effects */
        .glow {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
            animation: glowMove 8s ease-in-out infinite;
        }

        .glow-1 { width: 400px; height: 400px; background: rgba(0, 150, 255, 0.4); top: 10%; left: 20%; animation-delay: 0s; }
        .glow-2 { width: 300px; height: 300px; background: rgba(100, 220, 255, 0.3); bottom: 15%; left: 60%; animation-delay: 2s; }
        .glow-3 { width: 350px; height: 350px; background: rgba(0, 100, 200, 0.3); top: 40%; right: 10%; animation-delay: 4s; }

        @keyframes glowMove {
            0%, 100% { transform: translate(0, 0) scale(1); }
            33% { transform: translate(30px, -30px) scale(1.1); }
            66% { transform: translate(-20px, 20px) scale(0.9); }
        }

        /* Ring Effect Around Server */
        .ring {
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            border: 2px solid rgba(100, 220, 255, 0.3);
            border-radius: 50%;
            animation: ringExpand 3s ease-out infinite;
        }

        .ring-1 { animation-delay: 0s; }
        .ring-2 { animation-delay: 1s; }
        .ring-3 { animation-delay: 2s; }

        @keyframes ringExpand {
            0% { width: 120px; height: 120px; opacity: 1; border-width: 3px; }
            100% { width: 300px; height: 300px; opacity: 0; border-width: 0px; }
        }

        /* ===== LOG BUTTON ===== */
        .log-btn {
            position: absolute;
            bottom: 4%;
            left: 3%;
            background: rgba(255, 255, 255, 0.07);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(100, 220, 255, 0.25);
            border-radius: 8px;
            padding: 8px 16px;
            color: rgba(200, 230, 255, 0.8);
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            z-index: 25;
            box-shadow: 0 0 20px rgba(0, 100, 200, 0.15);
            transition: all 0.3s ease;
            animation: infoPanelFadeIn 1.5s ease-out forwards;
            opacity: 0;
            font-family: 'Karla', sans-serif;
        }

        .log-btn:hover {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(100, 220, 255, 0.5);
            box-shadow: 0 0 30px rgba(0, 100, 200, 0.25);
            color: #fff;
        }

        /* ===== LOG MODAL ===== */
        .log-modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
            z-index: 100;
            display: none;
            justify-content: center;
            align-items: center;
            animation: modalFadeIn 0.2s ease-out;
        }

        .log-modal-overlay.visible {
            display: flex;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .log-modal {
            width: 750px;
            max-width: 92vw;
            max-height: 80vh;
            background: rgba(10, 20, 50, 0.95);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(100, 220, 255, 0.25);
            border-radius: 14px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 0 60px rgba(0, 100, 200, 0.4),
                        0 20px 60px rgba(0, 0, 0, 0.5);
            animation: modalSlideIn 0.25s ease-out;
        }

        @keyframes modalSlideIn {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .log-modal .modal-header {
            display: flex;
            align-items: center;
            padding: 16px 22px;
            border-bottom: 1px solid rgba(100, 220, 255, 0.12);
            flex-shrink: 0;
        }

        .log-modal .modal-header span {
            color: rgba(255, 255, 255, 0.8);
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        .log-modal .modal-header .modal-close {
            margin-left: auto;
            background: none;
            border: none;
            color: rgba(100, 220, 255, 0.5);
            font-size: 18px;
            cursor: pointer;
            padding: 0 6px;
            line-height: 1;
            transition: color 0.2s;
            font-family: 'Karla', sans-serif;
        }

        .log-modal .modal-header .modal-close:hover {
            color: rgba(100, 220, 255, 1);
        }

        .log-modal .modal-body {
            padding: 8px 22px 16px;
            overflow-y: auto;
            flex: 1;
            scrollbar-width: thin;
            scrollbar-color: rgba(100, 220, 255, 0.15) transparent;
        }

        .log-modal .modal-body::-webkit-scrollbar {
            width: 5px;
        }

        .log-modal .modal-body::-webkit-scrollbar-thumb {
            background: rgba(100, 220, 255, 0.15);
            border-radius: 3px;
        }

        .log-modal .modal-body .log-entry {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 7px 0;
            font-size: 12px;
            font-family: 'Courier New', monospace;
            color: rgba(200, 230, 255, 0.85);
            border-bottom: 1px solid rgba(100, 220, 255, 0.06);
            line-height: 1.5;
            white-space: nowrap;
        }

        .log-modal .modal-body .log-entry .log-time {
            color: rgba(100, 220, 255, 0.45);
            font-size: 11px;
            min-width: 140px;
            flex-shrink: 0;
        }

        .log-modal .modal-body .log-entry .log-method {
            font-weight: 700;
            min-width: 44px;
            flex-shrink: 0;
        }

        .log-modal .modal-body .log-entry .log-method[data-method="GET"] { color: #66bb6a; }
        .log-modal .modal-body .log-entry .log-method[data-method="POST"] { color: #ffa726; }

        .log-modal .modal-body .log-entry .log-uri {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            color: rgba(200, 230, 255, 0.7);
        }

        .log-modal .modal-body .log-entry .log-client {
            color: rgba(150, 190, 230, 0.45);
            font-size: 11px;
            min-width: 110px;
            flex-shrink: 0;
        }

        .log-modal .modal-body .log-entry .log-duration {
            color: rgba(100, 220, 255, 0.45);
            font-size: 11px;
            min-width: 50px;
            text-align: right;
            flex-shrink: 0;
        }

        .log-modal .modal-body .log-empty {
            color: rgba(150, 190, 230, 0.35);
            font-size: 13px;
            text-align: center;
            padding: 40px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Background Glow Effects -->
        <div class="glow glow-1"></div>
        <div class="glow glow-2"></div>
        <div class="glow glow-3"></div>

        <!-- jRDC3 Title -->
        <div class="jrdc3-title">JRDC3</div>

        <!-- Expanding Rings -->
        <div class="ring ring-1"></div>
        <div class="ring ring-2"></div>
        <div class="ring ring-3"></div>

        <!-- Connection Lines -->
        <div class="connection connection-1"></div>
        <div class="connection connection-2"></div>
        <div class="connection connection-3"></div>

        <!-- Central Server Node -->
        <div class="server-node"></div>

        <!-- Device Nodes -->
        <div class="device device-1">
            <div class="device-label">B4A</div>
        </div>
        <div class="device device-2">
            <div class="device-label">B4i</div>
        </div>
        <div class="device device-3">
            <div class="device-label">B4J</div>
        </div>

        <!-- Data Particles -->
        <div class="particle particle-1" style="--tx: -250px; --ty: -130px;"></div>
        <div class="particle particle-2" style="--tx: 250px; --ty: -130px;"></div>
        <div class="particle particle-3" style="--tx: 0px; --ty: 130px;"></div>

        <!-- ===== INFO PANEL (Bottom Right) ===== -->
        <div class="info-panel">
            <div class="info-header">
                <div class="status-dot"></div>
                <span>Server Status</span>
            </div>
            <div class="info-row">
                <span class="info-label">Database</span>
                <span class="info-value">${Main.rdcConnector1.DbType}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Version</span>
                <span class="info-value">${NumberFormat2(Main.VERSION, 1, 2, 2, False)} ${Main.REVISION}</span>
            </div>
            <div class="info-connection" hx-get="/test" hx-trigger="load">
				<span style="color: white">Testing connection...</span>
            </div>
            <div class="info-timestamp">
                RemoteServer running &mdash; $DateTime{DateTime.Now}
            </div>
        </div>
        <!-- ===== LOG BUTTON ===== -->
        <button class="log-btn" onclick="toggleLogModal()">Request Log</button>

        <!-- ===== LOG MODAL ===== -->
        <div class="log-modal-overlay" id="log-modal-overlay" onclick="if(event.target===this)toggleLogModal()">
            <div class="log-modal" onclick="event.stopPropagation()">
                <div class="modal-header">
                    <span>Request Log</span>
                    <button class="modal-close" onclick="toggleLogModal()">&times;</button>
                </div>
                <div class="modal-body" id="log-modal-body"
                     hx-get="/log" hx-trigger="every 2s" hx-swap="innerHTML">
                    <div class="log-empty">No requests yet.</div>
                </div>
            </div>
        </div>

        <script>
        function toggleLogModal() {
            var overlay = document.getElementById('log-modal-overlay');
            overlay.classList.toggle('visible');
            if (overlay.classList.contains('visible')) {
                document.body.style.overflow = 'hidden';
                htmx.ajax('GET', '/log', {target: '#log-modal-body', swap: 'innerHTML'});
            } else {
                document.body.style.overflow = '';
            }
        }
        </script>
    </div>
</body>
</html>
<!-- Html code created using Qwen3.7-Plus: https://chat.qwen.ai/ -->"$
	Return Html
End Sub