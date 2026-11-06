/* @ds-bundle: {"format":4,"namespace":"BSM","components":[{"name":"Logo"},{"name":"Icon"},{"name":"Button"},{"name":"IconButton"},{"name":"Input"},{"name":"Select"},{"name":"Switch"},{"name":"Chip"},{"name":"StatusBadge"},{"name":"Badge"},{"name":"Rating"},{"name":"Avatar"},{"name":"ServiceCard"},{"name":"BarberCard"},{"name":"AppointmentCard"},{"name":"StatCard"},{"name":"Stepper"},{"name":"Calendar"},{"name":"SlotGrid"},{"name":"Countdown"},{"name":"Tabs"},{"name":"Table"},{"name":"Pagination"},{"name":"Modal"},{"name":"ConfirmDialog"},{"name":"Toast"},{"name":"Banner"},{"name":"Skeleton"},{"name":"EmptyState"},{"name":"Sidebar"},{"name":"Topbar"},{"name":"BottomNav"},{"name":"AgendaBoard"}]} */
(function () {
  'use strict';
  var React = window.React;
  var h = React.createElement;
  var F = React.Fragment;

  function cx() {
    var out = [];
    for (var i = 0; i < arguments.length; i++) { if (arguments[i]) out.push(arguments[i]); }
    return out.join(' ');
  }
  function rest(props, omit) {
    var o = {};
    for (var k in props) { if (Object.prototype.hasOwnProperty.call(props, k) && omit.indexOf(k) < 0) o[k] = props[k]; }
    return o;
  }

  /* ---------- formatting helpers (es-CO) ---------- */
  function formatCOP(n) {
    var s = Math.round(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return '$' + s;
  }
  function parseHM(t) { var p = String(t).split(':'); return (+p[0]) * 60 + (+p[1] || 0); }
  function formatTime(t, compact) {
    var m = typeof t === 'number' ? t : parseHM(t);
    var hh = Math.floor(m / 60), mm = m % 60;
    var suf = hh < 12 ? 'a. m.' : 'p. m.';
    var h12 = hh % 12 === 0 ? 12 : hh % 12;
    var base = h12 + ':' + (mm < 10 ? '0' : '') + mm;
    return compact ? base : base + ' ' + suf;
  }
  function formatDuration(min) {
    if (min < 60) return min + ' min';
    var hh = Math.floor(min / 60), mm = min % 60;
    return hh + ' h' + (mm ? ' ' + mm + ' min' : '');
  }
  function initials(name) {
    return String(name || '').trim().split(/\s+/).slice(0, 2).map(function (w) { return w.charAt(0).toUpperCase(); }).join('');
  }
  var MONTHS = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
  var MONTHS_SHORT = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  var WEEKDAYS_SHORT = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  var WEEKDAYS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];

  /* ---------- Icon ---------- */
  var ICONS = {"scissors":"<circle cx=\"6\" cy=\"6\" r=\"3\"/> <path d=\"M8.12 8.12 12 12\"/> <path d=\"M20 4 8.12 15.88\"/> <circle cx=\"6\" cy=\"18\" r=\"3\"/> <path d=\"M14.8 14.8 20 20\"/>","calendar":"<path d=\"M8 2v4\"/> <path d=\"M16 2v4\"/> <rect width=\"18\" height=\"18\" x=\"3\" y=\"4\" rx=\"2\"/> <path d=\"M3 10h18\"/>","calendar-days":"<path d=\"M8 2v4\"/> <path d=\"M16 2v4\"/> <rect width=\"18\" height=\"18\" x=\"3\" y=\"4\" rx=\"2\"/> <path d=\"M3 10h18\"/> <path d=\"M8 14h.01\"/> <path d=\"M12 14h.01\"/> <path d=\"M16 14h.01\"/> <path d=\"M8 18h.01\"/> <path d=\"M12 18h.01\"/> <path d=\"M16 18h.01\"/>","calendar-plus":"<path d=\"M8 2v4\"/> <path d=\"M16 2v4\"/> <path d=\"M21 13V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h8\"/> <path d=\"M3 10h18\"/> <path d=\"M16 19h6\"/> <path d=\"M19 16v6\"/>","calendar-clock":"<path d=\"M21 7.5V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h3.5\"/> <path d=\"M16 2v4\"/> <path d=\"M8 2v4\"/> <path d=\"M3 10h5\"/> <path d=\"M17.5 17.5 16 16.3V14\"/> <circle cx=\"16\" cy=\"16\" r=\"6\"/>","calendar-check":"<path d=\"M8 2v4\"/> <path d=\"M16 2v4\"/> <rect width=\"18\" height=\"18\" x=\"3\" y=\"4\" rx=\"2\"/> <path d=\"M3 10h18\"/> <path d=\"m9 16 2 2 4-4\"/>","calendar-x":"<path d=\"M8 2v4\"/> <path d=\"M16 2v4\"/> <rect width=\"18\" height=\"18\" x=\"3\" y=\"4\" rx=\"2\"/> <path d=\"M3 10h18\"/> <path d=\"m14 14-4 4\"/> <path d=\"m10 14 4 4\"/>","clock":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <polyline points=\"12 6 12 12 16 14\"/>","user":"<path d=\"M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2\"/> <circle cx=\"12\" cy=\"7\" r=\"4\"/>","users":"<path d=\"M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2\"/> <circle cx=\"9\" cy=\"7\" r=\"4\"/> <path d=\"M22 21v-2a4 4 0 0 0-3-3.87\"/> <path d=\"M16 3.13a4 4 0 0 1 0 7.75\"/>","user-x":"<path d=\"M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2\"/> <circle cx=\"9\" cy=\"7\" r=\"4\"/> <line x1=\"17\" x2=\"22\" y1=\"8\" y2=\"13\"/> <line x1=\"22\" x2=\"17\" y1=\"8\" y2=\"13\"/>","user-round":"<circle cx=\"12\" cy=\"8\" r=\"5\"/> <path d=\"M20 21a8 8 0 0 0-16 0\"/>","user-plus":"<path d=\"M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2\"/> <circle cx=\"9\" cy=\"7\" r=\"4\"/> <line x1=\"19\" x2=\"19\" y1=\"8\" y2=\"14\"/> <line x1=\"22\" x2=\"16\" y1=\"11\" y2=\"11\"/>","house":"<path d=\"M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8\"/> <path d=\"M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z\"/>","layout-dashboard":"<rect width=\"7\" height=\"9\" x=\"3\" y=\"3\" rx=\"1\"/> <rect width=\"7\" height=\"5\" x=\"14\" y=\"3\" rx=\"1\"/> <rect width=\"7\" height=\"9\" x=\"14\" y=\"12\" rx=\"1\"/> <rect width=\"7\" height=\"5\" x=\"3\" y=\"16\" rx=\"1\"/>","store":"<path d=\"m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7\"/> <path d=\"M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8\"/> <path d=\"M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4\"/> <path d=\"M2 7h20\"/> <path d=\"M22 7v3a2 2 0 0 1-2 2a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12a2 2 0 0 1-2-2V7\"/>","settings":"<path d=\"M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z\"/> <circle cx=\"12\" cy=\"12\" r=\"3\"/>","search":"<circle cx=\"11\" cy=\"11\" r=\"8\"/> <path d=\"m21 21-4.3-4.3\"/>","bell":"<path d=\"M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9\"/> <path d=\"M10.3 21a1.94 1.94 0 0 0 3.4 0\"/>","sun":"<circle cx=\"12\" cy=\"12\" r=\"4\"/> <path d=\"M12 2v2\"/> <path d=\"M12 20v2\"/> <path d=\"m4.93 4.93 1.41 1.41\"/> <path d=\"m17.66 17.66 1.41 1.41\"/> <path d=\"M2 12h2\"/> <path d=\"M20 12h2\"/> <path d=\"m6.34 17.66-1.41 1.41\"/> <path d=\"m19.07 4.93-1.41 1.41\"/>","moon":"<path d=\"M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z\"/>","log-out":"<path d=\"M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4\"/> <polyline points=\"16 17 21 12 16 7\"/> <line x1=\"21\" x2=\"9\" y1=\"12\" y2=\"12\"/>","menu":"<line x1=\"4\" x2=\"20\" y1=\"12\" y2=\"12\"/> <line x1=\"4\" x2=\"20\" y1=\"6\" y2=\"6\"/> <line x1=\"4\" x2=\"20\" y1=\"18\" y2=\"18\"/>","x":"<path d=\"M18 6 6 18\"/> <path d=\"m6 6 12 12\"/>","check":"<path d=\"M20 6 9 17l-5-5\"/>","check-check":"<path d=\"M18 6 7 17l-5-5\"/> <path d=\"m22 10-7.5 7.5L13 16\"/>","circle-check":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <path d=\"m9 12 2 2 4-4\"/>","circle-x":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <path d=\"m15 9-6 6\"/> <path d=\"m9 9 6 6\"/>","chevron-left":"<path d=\"m15 18-6-6 6-6\"/>","chevron-right":"<path d=\"m9 18 6-6-6-6\"/>","chevron-down":"<path d=\"m6 9 6 6 6-6\"/>","plus":"<path d=\"M5 12h14\"/> <path d=\"M12 5v14\"/>","pencil":"<path d=\"M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z\"/> <path d=\"m15 5 4 4\"/>","trash-2":"<path d=\"M3 6h18\"/> <path d=\"M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6\"/> <path d=\"M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2\"/> <line x1=\"10\" x2=\"10\" y1=\"11\" y2=\"17\"/> <line x1=\"14\" x2=\"14\" y1=\"11\" y2=\"17\"/>","map-pin":"<path d=\"M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0\"/> <circle cx=\"12\" cy=\"10\" r=\"3\"/>","navigation":"<polygon points=\"3 11 22 2 13 21 11 13 3 11\"/>","phone":"<path d=\"M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z\"/>","message-circle":"<path d=\"M7.9 20A9 9 0 1 0 4 16.1L2 22Z\"/>","globe":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <path d=\"M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20\"/> <path d=\"M2 12h20\"/>","star":"<path d=\"M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z\"/>","lock":"<rect width=\"18\" height=\"11\" x=\"3\" y=\"11\" rx=\"2\" ry=\"2\"/> <path d=\"M7 11V7a5 5 0 0 1 10 0v4\"/>","timer":"<line x1=\"10\" x2=\"14\" y1=\"2\" y2=\"2\"/> <line x1=\"12\" x2=\"15\" y1=\"14\" y2=\"11\"/> <circle cx=\"12\" cy=\"14\" r=\"8\"/>","hourglass":"<path d=\"M5 22h14\"/> <path d=\"M5 2h14\"/> <path d=\"M17 22v-4.172a2 2 0 0 0-.586-1.414L12 12l-4.414 4.414A2 2 0 0 0 7 17.828V22\"/> <path d=\"M7 2v4.172a2 2 0 0 0 .586 1.414L12 12l4.414-4.414A2 2 0 0 0 17 6.172V2\"/>","sparkles":"<path d=\"M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z\"/> <path d=\"M20 3v4\"/> <path d=\"M22 5h-4\"/> <path d=\"M4 17v2\"/> <path d=\"M5 18H3\"/>","droplets":"<path d=\"M7 16.3c2.2 0 4-1.83 4-4.05 0-1.16-.57-2.26-1.71-3.19S7.29 6.75 7 5.3c-.29 1.45-1.14 2.84-2.29 3.76S3 11.1 3 12.25c0 2.22 1.8 4.05 4 4.05z\"/> <path d=\"M12.56 6.6A10.97 10.97 0 0 0 14 3.02c.5 2.5 2 4.9 4 6.5s3 3.5 3 5.5a6.98 6.98 0 0 1-11.91 4.97\"/>","layers":"<path d=\"m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z\"/> <path d=\"m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65\"/> <path d=\"m22 12.65-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65\"/>","ellipsis":"<circle cx=\"12\" cy=\"12\" r=\"1\"/> <circle cx=\"19\" cy=\"12\" r=\"1\"/> <circle cx=\"5\" cy=\"12\" r=\"1\"/>","arrow-right":"<path d=\"M5 12h14\"/> <path d=\"m12 5 7 7-7 7\"/>","arrow-left":"<path d=\"m12 19-7-7 7-7\"/> <path d=\"M19 12H5\"/>","info":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <path d=\"M12 16v-4\"/> <path d=\"M12 8h.01\"/>","triangle-alert":"<path d=\"m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3\"/> <path d=\"M12 9v4\"/> <path d=\"M12 17h.01\"/>","circle-alert":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <line x1=\"12\" x2=\"12\" y1=\"8\" y2=\"12\"/> <line x1=\"12\" x2=\"12.01\" y1=\"16\" y2=\"16\"/>","refresh-cw":"<path d=\"M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8\"/> <path d=\"M21 3v5h-5\"/> <path d=\"M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16\"/> <path d=\"M8 16H3v5\"/>","eye":"<path d=\"M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0\"/> <circle cx=\"12\" cy=\"12\" r=\"3\"/>","eye-off":"<path d=\"M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49\"/> <path d=\"M14.084 14.158a3 3 0 0 1-4.242-4.242\"/> <path d=\"M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143\"/> <path d=\"m2 2 20 20\"/>","list-filter":"<path d=\"M3 6h18\"/> <path d=\"M7 12h10\"/> <path d=\"M10 18h4\"/>","wifi-off":"<path d=\"M12 20h.01\"/> <path d=\"M8.5 16.429a5 5 0 0 1 7 0\"/> <path d=\"M5 12.859a10 10 0 0 1 5.17-2.69\"/> <path d=\"M19 12.859a10 10 0 0 0-2.007-1.523\"/> <path d=\"M2 8.82a15 15 0 0 1 4.177-2.643\"/> <path d=\"M22 8.82a15 15 0 0 0-11.288-3.764\"/> <path d=\"m2 2 20 20\"/>","image-plus":"<path d=\"M16 5h6\"/> <path d=\"M19 2v6\"/> <path d=\"M21 11.5V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h7.5\"/> <path d=\"m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21\"/> <circle cx=\"9\" cy=\"9\" r=\"2\"/>","camera":"<path d=\"M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z\"/> <circle cx=\"12\" cy=\"13\" r=\"3\"/>","trending-up":"<polyline points=\"22 7 13.5 15.5 8.5 10.5 2 17\"/> <polyline points=\"16 7 22 7 22 13\"/>","trending-down":"<polyline points=\"22 17 13.5 8.5 8.5 13.5 2 7\"/> <polyline points=\"16 17 22 17 22 11\"/>","banknote":"<rect width=\"20\" height=\"12\" x=\"2\" y=\"6\" rx=\"2\"/> <circle cx=\"12\" cy=\"12\" r=\"2\"/> <path d=\"M6 12h.01M18 12h.01\"/>","clipboard-list":"<rect width=\"8\" height=\"4\" x=\"8\" y=\"2\" rx=\"1\" ry=\"1\"/> <path d=\"M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2\"/> <path d=\"M12 11h4\"/> <path d=\"M12 16h4\"/> <path d=\"M8 11h.01\"/> <path d=\"M8 16h.01\"/>","user-cog":"<circle cx=\"18\" cy=\"15\" r=\"3\"/> <circle cx=\"9\" cy=\"7\" r=\"4\"/> <path d=\"M10 15H6a4 4 0 0 0-4 4v2\"/> <path d=\"m21.7 16.4-.9-.3\"/> <path d=\"m15.2 13.9-.9-.3\"/> <path d=\"m16.6 18.7.3-.9\"/> <path d=\"m19.1 12.2.3-.9\"/> <path d=\"m19.6 18.7-.4-1\"/> <path d=\"m16.8 12.3-.4-1\"/> <path d=\"m14.3 16.6 1-.4\"/> <path d=\"m20.7 13.8 1-.4\"/>","shield-check":"<path d=\"M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z\"/> <path d=\"m9 12 2 2 4-4\"/>","circle":"<circle cx=\"12\" cy=\"12\" r=\"10\"/>","mail":"<rect width=\"20\" height=\"16\" x=\"2\" y=\"4\" rx=\"2\"/> <path d=\"m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7\"/>","key-round":"<path d=\"M2.586 17.414A2 2 0 0 0 2 18.828V21a1 1 0 0 0 1 1h3a1 1 0 0 0 1-1v-1a1 1 0 0 1 1-1h1a1 1 0 0 0 1-1v-1a1 1 0 0 1 1-1h.172a2 2 0 0 0 1.414-.586l.814-.814a6.5 6.5 0 1 0-4-4z\"/> <circle cx=\"16.5\" cy=\"7.5\" r=\".5\" fill=\"currentColor\"/>","history":"<path d=\"M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8\"/> <path d=\"M3 3v5h5\"/> <path d=\"M12 7v5l4 2\"/>","rotate-ccw":"<path d=\"M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8\"/> <path d=\"M3 3v5h5\"/>","badge-check":"<path d=\"M3.85 8.62a4 4 0 0 1 4.78-4.77 4 4 0 0 1 6.74 0 4 4 0 0 1 4.78 4.78 4 4 0 0 1 0 6.74 4 4 0 0 1-4.77 4.78 4 4 0 0 1-6.75 0 4 4 0 0 1-4.78-4.77 4 4 0 0 1 0-6.76Z\"/> <path d=\"m9 12 2 2 4-4\"/>","loader-circle":"<path d=\"M21 12a9 9 0 1 1-6.219-8.56\"/>","ban":"<circle cx=\"12\" cy=\"12\" r=\"10\"/> <path d=\"m4.9 4.9 14.2 14.2\"/>","navaja":"<path d=\"M5 4h13a2 2 0 0 1 2 2c0 3-2.2 5-5 5H9\"/><circle cx=\"6.5\" cy=\"7.5\" r=\"2.5\"/><path d=\"m8.2 9.3 9.3 10.2a1.5 1.5 0 0 1-2.2 2L6.4 10\"/>","barba":"<path d=\"M4 4v5a8 8 0 0 0 16 0V4\"/><path d=\"M8 12.5c1.6-1.2 3-1.2 4 .3 1-1.5 2.4-1.5 4-.3\"/><path d=\"M10 16.5h4\"/>"};
  var SERVICE_ICON = { Corte: 'scissors', Afeitado: 'navaja', Barba: 'barba', Tinte: 'droplets', Tratamiento: 'sparkles', Combo: 'layers', Otro: 'ellipsis' };

  function Icon(props) {
    var size = props.size || 20;
    var body = ICONS[props.name] || ICONS.circle;
    return h('svg', {
      className: cx('bsm-icon', props.className), width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
      stroke: 'currentColor', strokeWidth: props.strokeWidth || 2, strokeLinecap: 'round', strokeLinejoin: 'round',
      'aria-hidden': props.label ? undefined : 'true', role: props.label ? 'img' : undefined, 'aria-label': props.label,
      dangerouslySetInnerHTML: { __html: body }
    });
  }

  /* ---------- Logo ---------- */
  var POLE_STRIPES = (function () {
    var s = '';
    for (var i = 0, y = -30; y < 130; y += 14, i++) s += '<rect x="-40" y="' + y + '" width="160" height="7" fill="' + (i % 2 ? '#7B2D26' : '#C6A15B') + '"/>';
    return s;
  })();
  var uid = 0;
  function emblemMarkup(id) {
    var clip = '<clipPath id="bsm-pole-' + id + '"><rect x="26" y="18" width="20" height="58" rx="10"/></clipPath>';
    var pole = '<rect x="26" y="18" width="20" height="58" rx="10" fill="#F6F2EA"/><g clip-path="url(#bsm-pole-' + id + ')"><g transform="rotate(-35 36 47)">' + POLE_STRIPES + '</g></g>';
    var light = '<g class="bsm-logo-onlight"><path d="M0 84V36A36 36 0 0 1 72 36V84Z" fill="#1C1814"/><path d="M8 84V36A28 28 0 0 1 64 36V84" fill="none" stroke="#C6A15B" stroke-width="2.5"/>' + pole + '</g>';
    var dark = '<g class="bsm-logo-ondark"><path d="M2.5 84V36A33.5 33.5 0 0 1 69.5 36V84" fill="none" stroke="#C6A15B" stroke-width="5"/><path d="M8 84V36A28 28 0 0 1 64 36V84" fill="none" stroke="#C6A15B" stroke-width="1.75"/>' + pole + '</g>';
    return '<defs>' + clip + '</defs>' + light + dark;
  }
  function Logo(props) {
    var ref = React.useRef(null);
    if (ref.current === null) ref.current = ++uid;
    var variant = props.variant || 'horizontal';
    var height = props.height || (variant === 'emblem' ? 48 : 40);
    var surface = props.surface || 'auto';
    var mark = h('svg', { className: 'bsm-logo-mark', viewBox: '0 0 72 84', width: height * 72 / 84, height: height, 'aria-hidden': 'true', dangerouslySetInnerHTML: { __html: emblemMarkup(ref.current) } });
    var cls = cx('bsm-logo', 'bsm-logo-' + variant, 'bsm-logo-surface-' + surface, props.className);
    if (variant === 'emblem') return h('span', { className: cls, role: 'img', 'aria-label': 'BarberShop Medellín' }, mark);
    return h('span', { className: cls, role: 'img', 'aria-label': 'BarberShop Medellín', style: { '--bsm-logo-h': height + 'px' } },
      mark,
      h('span', { className: 'bsm-logo-words', 'aria-hidden': 'true' },
        h('span', { className: 'bsm-logo-name' }, 'BarberShop'),
        h('span', { className: 'bsm-logo-city' }, 'Medellín')));
  }

  /* ---------- Button ---------- */
  function Button(props) {
    var variant = props.variant || 'primary';
    var size = props.size || 'md';
    var other = rest(props, ['variant', 'size', 'icon', 'iconRight', 'loading', 'block', 'className', 'children', 'disabled']);
    var iconSize = size === 'sm' ? 16 : 20;
    return h('button', Object.assign({ type: 'button' }, other, {
      className: cx('bsm-btn', 'bsm-btn-' + variant, 'bsm-btn-' + size, props.block && 'bsm-btn-block', props.loading && 'is-loading', props.className),
      disabled: props.disabled || props.loading, 'aria-busy': props.loading ? 'true' : undefined
    }),
      props.loading ? h(Icon, { name: 'loader-circle', size: iconSize, className: 'bsm-spin' }) : (props.icon ? h(Icon, { name: props.icon, size: iconSize }) : null),
      props.children != null ? h('span', null, props.children) : null,
      props.iconRight && !props.loading ? h(Icon, { name: props.iconRight, size: iconSize }) : null);
  }
  function IconButton(props) {
    var other = rest(props, ['icon', 'label', 'variant', 'className', 'badge', 'size']);
    return h('button', Object.assign({ type: 'button' }, other, {
      className: cx('bsm-iconbtn', 'bsm-iconbtn-' + (props.variant || 'ghost'), props.size === 'sm' && 'bsm-iconbtn-sm', props.className), 'aria-label': props.label, title: props.label
    }), h(Icon, { name: props.icon, size: props.size === 'sm' ? 18 : 20 }), props.badge ? h('span', { className: 'bsm-iconbtn-dot', 'aria-hidden': 'true' }) : null);
  }

  /* ---------- Form fields ---------- */
  var fieldId = 0;
  function useId(given) {
    var r = React.useRef(given || null);
    if (r.current === null) r.current = 'bsm-f' + (++fieldId);
    return r.current;
  }
  function Field(props, control) {
    var id = props.id;
    return h('div', { className: cx('bsm-field', props.error && 'has-error', props.disabled && 'is-disabled', props.className) },
      props.label ? h('label', { className: 'bsm-field-label', htmlFor: id }, props.label, props.optional ? h('span', { className: 'bsm-field-opt' }, ' (opcional)') : null) : null,
      control,
      props.error ? h('p', { className: 'bsm-field-msg bsm-field-error', id: id + '-msg' }, h(Icon, { name: 'circle-alert', size: 16 }), props.error)
        : props.hint ? h('p', { className: 'bsm-field-msg', id: id + '-msg' }, props.hint) : null);
  }
  function Input(props) {
    var id = useId(props.id);
    var show = React.useState(false);
    var other = rest(props, ['label', 'hint', 'error', 'icon', 'trailing', 'optional', 'className', 'id', 'multiline', 'revealable']);
    if (props.revealable) other.type = show[0] ? 'text' : 'password';
    var describedBy = (props.error || props.hint) ? id + '-msg' : undefined;
    var trailing = props.trailing || (props.revealable ? h(IconButton, {
      icon: show[0] ? 'eye-off' : 'eye', label: show[0] ? 'Ocultar contraseña' : 'Mostrar contraseña',
      'aria-pressed': show[0] ? 'true' : 'false', onClick: function () { show[1](!show[0]); }
    }) : null);
    var control = h('div', { className: cx('bsm-control', props.icon && 'has-icon', props.multiline && 'is-multiline') },
      props.icon ? h(Icon, { name: props.icon, size: 20, className: 'bsm-control-icon' }) : null,
      h(props.multiline ? 'textarea' : 'input', Object.assign({ id: id, className: 'bsm-control-input', 'aria-invalid': props.error ? 'true' : undefined, 'aria-describedby': describedBy, rows: props.multiline ? 3 : undefined }, other)),
      trailing);
    return Field(Object.assign({}, props, { id: id }), control);
  }
  function Select(props) {
    var id = useId(props.id);
    var other = rest(props, ['label', 'hint', 'error', 'options', 'optional', 'className', 'id', 'placeholder']);
    var control = h('div', { className: 'bsm-control bsm-select' },
      h('select', Object.assign({ id: id, className: 'bsm-control-input', 'aria-invalid': props.error ? 'true' : undefined, 'aria-describedby': (props.error || props.hint) ? id + '-msg' : undefined }, other),
        props.placeholder ? h('option', { value: '' }, props.placeholder) : null,
        (props.options || []).map(function (o) { var v = typeof o === 'string' ? o : o.value; return h('option', { key: v, value: v }, typeof o === 'string' ? o : o.label); })),
      h(Icon, { name: 'chevron-down', size: 20, className: 'bsm-select-chevron' }));
    return Field(Object.assign({}, props, { id: id }), control);
  }
  function Switch(props) {
    var id = useId(props.id);
    var st = React.useState(!!props.defaultChecked);
    var checked = props.checked != null ? props.checked : st[0];
    function toggle() { if (props.disabled) return; if (props.checked == null) st[1](!checked); if (props.onChange) props.onChange(!checked); }
    return h('div', { className: cx('bsm-switch-row', props.disabled && 'is-disabled') },
      h('span', { className: 'bsm-switch-text' },
        h('label', { htmlFor: id, className: 'bsm-switch-label' }, props.label),
        props.hint ? h('span', { className: 'bsm-switch-hint' }, props.hint) : null),
      h('button', { id: id, type: 'button', role: 'switch', 'aria-checked': checked ? 'true' : 'false', disabled: props.disabled, className: 'bsm-switch', onClick: toggle },
        h('span', { className: 'bsm-switch-thumb' }, checked ? h(Icon, { name: 'check', size: 14, strokeWidth: 3 }) : null)));
  }
  function Chip(props) {
    var other = rest(props, ['selected', 'icon', 'onRemove', 'count', 'className', 'children', 'as']);
    if (props.as === 'tag') return h('span', { className: cx('bsm-chip', 'bsm-chip-tag', props.className) }, props.children);
    return h('button', Object.assign({ type: 'button', 'aria-pressed': props.onRemove ? undefined : (props.selected ? 'true' : 'false') }, other, {
      className: cx('bsm-chip', props.selected && 'is-selected', props.onRemove && 'bsm-chip-input', props.className)
    }),
      props.selected && !props.onRemove ? h(Icon, { name: 'check', size: 16 }) : (props.icon ? h(Icon, { name: props.icon, size: 16 }) : null),
      h('span', null, props.children),
      props.count != null ? h('span', { className: 'bsm-chip-count' }, props.count) : null,
      props.onRemove ? h('span', { className: 'bsm-chip-x', role: 'button', 'aria-label': 'Quitar ' + props.children, onClick: props.onRemove }, h(Icon, { name: 'x', size: 16 })) : null);
  }

  /* ---------- Status ---------- */
  var STATUS = {
    Pendiente: { label: 'Pendiente', icon: 'hourglass', key: 'pendiente' },
    Confirmada: { label: 'Confirmada', icon: 'circle-check', key: 'confirmada' },
    EnProgreso: { label: 'En progreso', icon: 'scissors', key: 'enprogreso' },
    Completada: { label: 'Completada', icon: 'check-check', key: 'completada' },
    Cancelada: { label: 'Cancelada', icon: 'circle-x', key: 'cancelada' },
    NoShow: { label: 'No asistió', icon: 'user-x', key: 'noshow' }
  };
  function StatusBadge(props) {
    var s = STATUS[props.status] || STATUS.Pendiente;
    return h('span', { className: cx('bsm-badge', 'bsm-status-' + s.key, props.size === 'sm' && 'bsm-badge-sm', props.className) },
      h(Icon, { name: s.icon, size: 14, strokeWidth: 2.25 }), s.label);
  }
  function Badge(props) {
    return h('span', { className: cx('bsm-badge', 'bsm-tone-' + (props.tone || 'neutral'), props.className) },
      props.icon ? h(Icon, { name: props.icon, size: 14, strokeWidth: 2.25 }) : null, props.children);
  }
  function Rating(props) {
    var v = props.value || 0;
    var stars = [];
    for (var i = 1; i <= 5; i++) {
      var fill = v >= i - 0.25 ? 'full' : v >= i - 0.75 ? 'half' : 'empty';
      stars.push(h('span', { key: i, className: 'bsm-star bsm-star-' + fill }, h(Icon, { name: 'star', size: props.size || 16 }),
        fill === 'half' ? h('span', { className: 'bsm-star-fill' }, h(Icon, { name: 'star', size: props.size || 16 })) : null));
    }
    var txt = v.toFixed(1).replace('.', ',');
    return h('span', { className: cx('bsm-rating', props.compact && 'is-compact', props.className), role: 'img', 'aria-label': 'Calificación ' + txt + ' de 5' + (props.count != null ? ', ' + props.count + ' reseñas' : '') },
      props.compact ? h('span', { className: 'bsm-star bsm-star-full' }, h(Icon, { name: 'star', size: props.size || 16 })) : stars,
      h('span', { className: 'bsm-rating-value', 'aria-hidden': 'true' }, txt),
      props.count != null ? h('span', { className: 'bsm-rating-count', 'aria-hidden': 'true' }, '(' + props.count + ')') : null);
  }
  function Avatar(props) {
    var size = props.size || 48;
    var style = { width: size, height: size, fontSize: Math.round(size * 0.38) };
    return h('span', { className: cx('bsm-avatar', props.className), style: style, title: props.name },
      props.src ? h('img', { src: props.src, alt: props.name || '' }) : h('span', { 'aria-hidden': props.name ? undefined : 'true' }, initials(props.name)),
      props.status ? h('span', { className: 'bsm-avatar-dot bsm-avatar-dot-' + props.status, 'aria-label': props.status === 'on' ? 'Disponible' : 'No disponible' }) : null);
  }

  /* ---------- Booking cards ---------- */
  function ServiceCard(props) {
    var type = props.type || 'Corte';
    return h('button', {
      type: 'button', role: 'radio', 'aria-checked': props.selected ? 'true' : 'false',
      className: cx('bsm-card', 'bsm-card-press', 'bsm-service', props.selected && 'is-selected', props.className), onClick: props.onClick
    },
      props.image ? h('img', { className: 'bsm-service-img', src: props.image, alt: '' })
        : h('span', { className: 'bsm-service-icon' }, h(Icon, { name: SERVICE_ICON[type] || 'scissors', size: 24 })),
      h('span', { className: 'bsm-service-body' },
        h('span', { className: 'bsm-service-top' },
          h('span', { className: 'bsm-card-title' }, props.name),
          props.tag ? h(Badge, { tone: 'oxblood' }, props.tag) : null),
        props.description ? h('span', { className: 'bsm-card-desc' }, props.description) : null,
        h('span', { className: 'bsm-service-meta' },
          h('span', { className: 'bsm-meta' }, h(Icon, { name: 'clock', size: 16 }), formatDuration(props.duration || 30)),
          h('span', { className: 'bsm-price' }, typeof props.price === 'number' ? formatCOP(props.price) : props.price))),
      props.selected ? h('span', { className: 'bsm-card-check', 'aria-hidden': 'true' }, h(Icon, { name: 'check', size: 16, strokeWidth: 3 })) : null);
  }
  function BarberCard(props) {
    var unavailable = props.available === false;
    return h('div', { className: cx('bsm-card', 'bsm-barber', props.selected && 'is-selected', unavailable && 'is-unavailable', props.className) },
      h('button', { type: 'button', role: 'radio', 'aria-checked': props.selected ? 'true' : 'false', 'aria-disabled': unavailable ? 'true' : undefined, className: 'bsm-barber-hit', onClick: unavailable ? undefined : props.onClick },
        h(Avatar, { name: props.name, src: props.photo, size: 64 }),
        h('span', { className: 'bsm-barber-body' },
          h('span', { className: 'bsm-card-title' }, props.name),
          h('span', { className: 'bsm-barber-line' },
            props.rating != null ? h(Rating, { value: props.rating, count: props.reviews, compact: true }) : null,
            h('span', { className: 'bsm-dot-sep', 'aria-hidden': 'true' }, '·'),
            h('span', { className: 'bsm-meta' }, props.years + (props.years === 1 ? ' año' : ' años') + ' de experiencia')),
          (props.specialties && props.specialties.length) ? h('span', { className: 'bsm-chip-row' },
            props.specialties.slice(0, 3).map(function (s) { return h(Chip, { key: s, as: 'tag' }, s); })) : null,
          unavailable ? h(Badge, { tone: 'neutral', icon: 'calendar-x' }, props.unavailableLabel || 'No disponible hoy') : null),
        props.selected ? h('span', { className: 'bsm-card-check', 'aria-hidden': 'true' }, h(Icon, { name: 'check', size: 16, strokeWidth: 3 })) : null),
      props.onProfile ? h('button', { type: 'button', className: 'bsm-link bsm-barber-profile', onClick: props.onProfile }, 'Ver perfil', h(Icon, { name: 'chevron-right', size: 16 })) : null);
  }
  /* actions: React nodes, or plain objects {label, variant, icon, onClick} (for canvases and data-driven lists) */
  function toActions(list, defaultSize) {
    return [].concat(list).map(function (a, i) {
      if (a == null || React.isValidElement(a)) return a;
      var variant = a.variant || 'secondary', size = a.size || defaultSize || 'sm';
      if (a.href) {
        return h('a', { key: a.label || i, href: a.href, className: cx('bsm-btn', 'bsm-btn-' + variant, 'bsm-btn-' + size) },
          a.icon ? h(Icon, { name: a.icon, size: size === 'sm' ? 16 : 20 }) : null, h('span', null, a.label));
      }
      return h(Button, { key: a.label || i, variant: variant, size: size, icon: a.icon, onClick: a.onClick }, a.label);
    });
  }
  function AppointmentCard(props) {
    var d = props.date instanceof Date ? props.date : new Date(props.date + 'T12:00:00');
    return h('article', { className: cx('bsm-card', 'bsm-appt', props.className) },
      h('div', { className: 'bsm-appt-date', 'aria-hidden': 'true' },
        h('span', { className: 'bsm-appt-wd' }, WEEKDAYS[d.getDay()].slice(0, 3)),
        h('span', { className: 'bsm-appt-day' }, d.getDate()),
        h('span', { className: 'bsm-appt-mon' }, MONTHS_SHORT[d.getMonth()])),
      h('div', { className: 'bsm-appt-body' },
        h('div', { className: 'bsm-appt-head' },
          h('h3', { className: 'bsm-card-title' }, props.service),
          h(StatusBadge, { status: props.status })),
        h('p', { className: 'bsm-appt-line' }, h(Avatar, { name: props.barber, src: props.barberPhoto, size: 24 }), 'con ' + props.barber),
        h('p', { className: 'bsm-appt-line bsm-meta' }, h(Icon, { name: 'clock', size: 16 }),
          h('span', { className: 'bsm-sr' }, WEEKDAYS[d.getDay()] + ' ' + d.getDate() + ' de ' + MONTHS[d.getMonth()] + ', '),
          formatTime(props.start) + ' – ' + formatTime(props.end),
          props.price != null ? h('span', { className: 'bsm-appt-price' }, formatCOP(props.price)) : null),
        props.actions ? h('div', { className: 'bsm-appt-actions' }, toActions(props.actions)) : null));
  }
  function StatCard(props) {
    var up = props.delta != null && props.delta >= 0;
    var good = props.invert ? !up : up;
    return h('section', { className: cx('bsm-card', 'bsm-stat', props.className) },
      h('div', { className: 'bsm-stat-head' },
        h('span', { className: 'bsm-stat-label' }, props.label),
        props.icon ? h('span', { className: 'bsm-stat-icon' }, h(Icon, { name: props.icon, size: 20 })) : null),
      h('p', { className: 'bsm-stat-value' }, props.value),
      props.delta != null ? h('p', { className: cx('bsm-stat-delta', good ? 'is-good' : 'is-bad') },
        h(Icon, { name: up ? 'trending-up' : 'trending-down', size: 16 }),
        h('strong', null, (up ? '+' : '−') + Math.abs(props.delta).toString().replace('.', ',') + ' %'),
        h('span', null, ' ' + (props.deltaLabel || 'vs. semana pasada'))) : (props.hint ? h('p', { className: 'bsm-stat-delta' }, props.hint) : null));
  }

  /* ---------- Booking flow ---------- */
  function Stepper(props) {
    var steps = props.steps || ['Servicio', 'Barbero', 'Horario', 'Confirmar'];
    var cur = props.current || 1;
    return h('nav', { className: 'bsm-stepper', 'aria-label': 'Progreso de la reserva' },
      h('p', { className: 'bsm-stepper-count' }, h('strong', null, 'Paso ' + cur + ' de ' + steps.length), ' · ' + steps[cur - 1]),
      h('ol', { className: 'bsm-stepper-list' }, steps.map(function (s, i) {
        var n = i + 1; var state = n < cur ? 'done' : n === cur ? 'current' : 'todo';
        return h('li', { key: s, className: 'bsm-step is-' + state, 'aria-current': state === 'current' ? 'step' : undefined },
          h('span', { className: 'bsm-step-bar' }),
          h('span', { className: 'bsm-step-label' }, state === 'done' ? h(Icon, { name: 'check', size: 14, strokeWidth: 3 }) : null, s));
      })));
  }
  function Calendar(props) {
    var y = props.year, m = props.month; // month 0-11
    var first = new Date(y, m, 1);
    var offset = (first.getDay() + 6) % 7; // lunes primero
    var days = new Date(y, m + 1, 0).getDate();
    var cells = [];
    for (var i = 0; i < offset; i++) cells.push(null);
    for (var d = 1; d <= days; d++) cells.push(d);
    var disabled = props.disabled || function () { return false; };
    var marks = props.marks || {};
    return h('div', { className: cx('bsm-cal', props.className) },
      h('div', { className: 'bsm-cal-head' },
        h('h3', { className: 'bsm-cal-title' }, MONTHS[m].charAt(0).toUpperCase() + MONTHS[m].slice(1) + ' ' + y),
        h('div', { className: 'bsm-cal-nav' },
          h(IconButton, { icon: 'chevron-left', label: 'Mes anterior', size: 'sm' }),
          h(IconButton, { icon: 'chevron-right', label: 'Mes siguiente', size: 'sm' }))),
      h('div', { className: 'bsm-cal-grid', role: 'grid' },
        WEEKDAYS_SHORT.map(function (w, i) { return h('span', { key: 'w' + i, className: 'bsm-cal-wd', role: 'columnheader', 'aria-label': ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'][i] }, w); }),
        cells.map(function (d, i) {
          if (d == null) return h('span', { key: 'e' + i });
          var dis = disabled(d);
          var sel = props.selected === d;
          var today = props.today === d;
          return h('button', {
            key: d, type: 'button', role: 'gridcell', disabled: dis, 'aria-selected': sel ? 'true' : undefined, 'aria-current': today ? 'date' : undefined,
            className: cx('bsm-cal-day', sel && 'is-selected', today && 'is-today', dis && 'is-disabled')
          }, h('span', null, d), marks[d] ? h('span', { className: 'bsm-cal-mark bsm-cal-mark-' + marks[d] }) : null);
        })),
      props.legend ? h('p', { className: 'bsm-cal-legend' }, props.legend) : null);
  }
  var SLOT_ADMIN = {
    available: { label: 'Disponible', icon: 'circle' },
    booked: { label: 'Ocupado', icon: 'calendar-check' },
    blocked: { label: 'Bloqueado', icon: 'lock' },
    hold: { label: 'Reservando', icon: 'timer' }
  };
  function SlotGrid(props) {
    var slots = props.slots || [];
    var admin = props.mode === 'admin';
    var groups = [['Mañana', 0, 720], ['Tarde', 720, 1080], ['Noche', 1080, 1440]];
    if (admin) {
      return h('div', { className: 'bsm-slots is-admin' },
        h('ul', { className: 'bsm-slot-legend', 'aria-label': 'Leyenda' }, Object.keys(SLOT_ADMIN).map(function (k) {
          return h('li', { key: k, className: 'bsm-slot-key bsm-slotstate-' + k }, h(Icon, { name: SLOT_ADMIN[k].icon, size: 16 }), SLOT_ADMIN[k].label);
        })),
        h('div', { className: 'bsm-slot-grid' }, slots.map(function (s) {
          var st = SLOT_ADMIN[s.state] || SLOT_ADMIN.available;
          return h('button', { key: s.time, type: 'button', className: 'bsm-slot bsm-slotstate-' + s.state, 'aria-label': formatTime(s.time) + ', ' + st.label + (s.note ? ', ' + s.note : '') },
            h('span', { className: 'bsm-slot-time' }, formatTime(s.time)),
            h('span', { className: 'bsm-slot-state' }, h(Icon, { name: st.icon, size: 14, strokeWidth: 2.25 }), s.note || st.label));
        })));
    }
    return h('div', { className: 'bsm-slots', role: 'radiogroup', 'aria-label': props.label || 'Horarios disponibles' },
      groups.map(function (g) {
        var inG = slots.filter(function (s) { var m = parseHM(s.time); return m >= g[1] && m < g[2]; });
        if (!inG.length) return null;
        return h('section', { key: g[0], className: 'bsm-slot-group' },
          h('h4', { className: 'bsm-overline' }, g[0], h('span', { className: 'bsm-slot-sfx' }, g[1] < 720 ? ' · a. m.' : ' · p. m.')),
          h('div', { className: 'bsm-slot-grid' }, inG.map(function (s) {
            var sel = props.selected === s.time;
            var off = s.state && s.state !== 'available';
            return h('button', {
              key: s.time, type: 'button', role: 'radio', 'aria-checked': sel ? 'true' : 'false', disabled: off,
              'aria-label': formatTime(s.time) + (off ? ', no disponible' : ''),
              className: cx('bsm-slot', sel && 'is-selected', off && 'is-off')
            }, formatTime(s.time, true));
          })));
      }));
  }
  function Countdown(props) {
    var total = props.total || 300;
    var s = Math.max(0, props.seconds);
    var mm = Math.floor(s / 60), ss = s % 60;
    var low = s <= 60;
    var txt = mm + ':' + (ss < 10 ? '0' : '') + ss;
    return h('div', { className: cx('bsm-countdown', low && 'is-low', props.variant === 'compact' && 'is-compact'), role: 'timer', 'aria-live': 'off', 'aria-label': 'Tiempo restante ' + mm + ' minutos ' + ss + ' segundos' },
      h(Icon, { name: 'timer', size: 20 }),
      h('div', { className: 'bsm-countdown-text' },
        h('span', { className: 'bsm-countdown-label' }, low ? 'Tu horario se libera en' : (props.label || 'Horario apartado por')),
        props.variant === 'compact' ? null : h('span', { className: 'bsm-countdown-hint' }, low ? 'Confirma ahora para no perderlo.' : 'Lo guardamos 5 min mientras confirmas.')),
      h('span', { className: 'bsm-countdown-time' }, txt),
      h('span', { className: 'bsm-countdown-bar', 'aria-hidden': 'true' }, h('span', { style: { width: (s / total * 100) + '%' } })));
  }

  /* ---------- Navigation & structure ---------- */
  function Tabs(props) {
    var items = props.items || [];
    var variant = props.variant || 'underline';
    return h('div', { className: cx('bsm-tabs', 'bsm-tabs-' + variant, props.className), role: 'tablist', 'aria-label': props.label },
      items.map(function (it) {
        var v = typeof it === 'string' ? it : it.value;
        var active = props.value === v;
        return h('button', { key: v, type: 'button', role: 'tab', 'aria-selected': active ? 'true' : 'false', tabIndex: active ? 0 : -1, className: cx('bsm-tab', active && 'is-active'), onClick: props.onChange ? function () { props.onChange(v); } : undefined },
          it.icon ? h(Icon, { name: it.icon, size: 18 }) : null,
          typeof it === 'string' ? it : it.label,
          it.count != null ? h('span', { className: 'bsm-tab-count' }, it.count) : null);
      }));
  }
  function Table(props) {
    var cols = props.columns || [];
    return h('div', { className: cx('bsm-table-wrap', props.className) },
      h('table', { className: 'bsm-table' },
        props.caption ? h('caption', { className: 'bsm-sr' }, props.caption) : null,
        h('thead', null, h('tr', null, cols.map(function (c) {
          return h('th', { key: c.key, scope: 'col', className: cx(c.align === 'right' && 'is-num', c.sort && 'is-sorted'), 'aria-sort': c.sort === 'asc' ? 'ascending' : c.sort === 'desc' ? 'descending' : undefined },
            c.label, c.sort ? h(Icon, { name: c.sort === 'asc' ? 'chevron-down' : 'chevron-down', size: 14, className: c.sort === 'asc' ? 'bsm-flip' : '' }) : null);
        }))),
        h('tbody', null, (props.rows || []).map(function (r, i) {
          return h('tr', { key: r.id || i, className: r.selected ? 'is-selected' : undefined }, cols.map(function (c) {
            var v = c.render ? c.render(r) : r[c.key];
            return h('td', { key: c.key, className: cx(c.align === 'right' && 'is-num', c.muted && 'is-muted') }, v);
          }));
        }))));
  }
  function Pagination(props) {
    if (props.variant === 'more') {
      return h('div', { className: 'bsm-pager is-more' },
        h('p', { className: 'bsm-pager-info' }, 'Mostrando ' + props.shown + ' de ' + props.total),
        h(Button, { variant: 'secondary', icon: props.loading ? null : 'history', loading: props.loading }, props.loading ? 'Cargando…' : 'Cargar más'));
    }
    var page = props.page || 1, pages = props.pages || 1, per = props.perPage || 25;
    var from = (page - 1) * per + 1, to = Math.min(page * per, props.total || pages * per);
    var list = [];
    for (var p = 1; p <= pages; p++) {
      if (p === 1 || p === pages || Math.abs(p - page) <= 1) list.push(p);
      else if (list[list.length - 1] !== '…') list.push('…');
    }
    return h('nav', { className: 'bsm-pager', 'aria-label': 'Paginación' },
      h('p', { className: 'bsm-pager-info' }, from + '–' + to + ' de ' + props.total),
      h('div', { className: 'bsm-pager-pages' },
        h(IconButton, { icon: 'chevron-left', label: 'Página anterior', size: 'sm', disabled: page === 1 }),
        list.map(function (p, i) {
          return p === '…' ? h('span', { key: 'g' + i, className: 'bsm-pager-gap' }, '…')
            : h('button', { key: p, type: 'button', className: cx('bsm-pager-page', p === page && 'is-active'), 'aria-current': p === page ? 'page' : undefined }, p);
        }),
        h(IconButton, { icon: 'chevron-right', label: 'Página siguiente', size: 'sm', disabled: page === pages })));
  }
  function Modal(props) {
    return h('div', { className: cx('bsm-scrim', props.inline && 'is-inline') },
      h('div', { className: cx('bsm-modal', props.sheet && 'is-sheet', props.size === 'lg' && 'is-lg'), role: 'dialog', 'aria-modal': 'true', 'aria-labelledby': 'bsm-modal-t' },
        props.sheet ? h('span', { className: 'bsm-sheet-handle', 'aria-hidden': 'true' }) : null,
        h('header', { className: 'bsm-modal-head' },
          h('div', null, h('h2', { id: 'bsm-modal-t', className: 'bsm-modal-title' }, props.title), props.subtitle ? h('p', { className: 'bsm-modal-sub' }, props.subtitle) : null),
          h(IconButton, { icon: 'x', label: 'Cerrar' })),
        h('div', { className: 'bsm-modal-body' }, props.children),
        props.footer ? h('footer', { className: 'bsm-modal-foot' }, toActions(props.footer, 'md')) : null));
  }
  function ConfirmDialog(props) {
    var tone = props.tone || 'danger';
    return h('div', { className: cx('bsm-scrim', props.inline && 'is-inline') },
      h('div', { className: 'bsm-modal bsm-confirm', role: 'alertdialog', 'aria-modal': 'true', 'aria-labelledby': 'bsm-confirm-t', 'aria-describedby': 'bsm-confirm-d' },
        h('span', { className: 'bsm-confirm-icon bsm-tone-' + tone }, h(Icon, { name: props.icon || (tone === 'danger' ? 'triangle-alert' : 'info'), size: 24 })),
        h('h2', { id: 'bsm-confirm-t', className: 'bsm-confirm-title' }, props.title),
        h('p', { id: 'bsm-confirm-d', className: 'bsm-confirm-body' }, props.body),
        h('div', { className: 'bsm-confirm-actions' },
          h(Button, { variant: 'secondary' }, props.cancelLabel || 'Volver'),
          h(Button, { variant: tone === 'danger' ? 'danger' : 'primary' }, props.confirmLabel))));
  }
  var TONE_ICON = { success: 'circle-check', warning: 'triangle-alert', danger: 'circle-alert', info: 'info', brass: 'timer', neutral: 'info' };
  function Toast(props) {
    var tone = props.tone || 'success';
    return h('div', { className: 'bsm-toast', role: tone === 'danger' ? 'alert' : 'status' },
      h(Icon, { name: props.icon || TONE_ICON[tone], size: 20 }),
      h('p', { className: 'bsm-toast-text' }, props.children),
      props.action ? h('button', { type: 'button', className: 'bsm-toast-action' }, props.action) : null,
      props.dismissible ? h('button', { type: 'button', className: 'bsm-toast-x', 'aria-label': 'Cerrar' }, h(Icon, { name: 'x', size: 18 })) : null);
  }
  function Banner(props) {
    var tone = props.tone || 'info';
    return h('div', { className: cx('bsm-banner', 'bsm-tone-' + tone, props.className), role: tone === 'danger' || tone === 'warning' ? 'alert' : 'status' },
      h(Icon, { name: props.icon || TONE_ICON[tone], size: 20 }),
      h('div', { className: 'bsm-banner-text' },
        props.title ? h('p', { className: 'bsm-banner-title' }, props.title) : null,
        props.children ? h('p', { className: 'bsm-banner-body' }, props.children) : null),
      props.action ? h('button', { type: 'button', className: 'bsm-banner-action' }, props.action) : null);
  }
  function Skeleton(props) {
    var v = props.variant || 'text';
    var b = function (w, hgt, r) { return h('span', { className: 'bsm-skel', style: { width: w, height: hgt, borderRadius: r } }); };
    var inner;
    if (v === 'card') inner = h('div', { className: 'bsm-card bsm-skel-card' }, b(48, 48, 'var(--radius-sm)'), h('div', { className: 'bsm-skel-lines' }, b('60%', 16), b('90%', 12), b('40%', 12)));
    else if (v === 'slots') inner = h('div', { className: 'bsm-slot-grid' }, [0, 1, 2, 3, 4, 5, 6, 7].map(function (i) { return h('span', { key: i, className: 'bsm-skel', style: { height: 44, borderRadius: 'var(--radius-sm)' } }); }));
    else if (v === 'row') inner = h('div', { className: 'bsm-skel-row' }, b(32, 32, '50%'), b('24%', 14), b('30%', 14), b('14%', 14), b(80, 22, 'var(--radius-xs)'));
    else inner = h('div', { className: 'bsm-skel-lines' }, b('70%', 14), b('100%', 14), b('55%', 14));
    return h('div', { className: 'bsm-skel-wrap', 'aria-busy': 'true', 'aria-label': props.label || 'Cargando' }, inner);
  }
  function EmptyState(props) {
    return h('div', { className: cx('bsm-empty', props.tone === 'error' && 'is-error', props.className) },
      h('span', { className: 'bsm-empty-icon' }, h(Icon, { name: props.icon || 'calendar', size: 28 })),
      h('h3', { className: 'bsm-empty-title' }, props.title),
      props.body ? h('p', { className: 'bsm-empty-body' }, props.body) : null,
      props.action || (props.actionLabel ? h(Button, { variant: props.actionVariant || 'primary', icon: props.actionIcon, onClick: props.onAction }, props.actionLabel) : null));
  }
  function Sidebar(props) {
    return h('aside', { className: 'bsm-sidebar', 'aria-label': 'Navegación principal' },
      h('div', { className: 'bsm-sidebar-brand' }, h(Logo, { variant: 'horizontal', height: 36 })),
      h('nav', { className: 'bsm-sidebar-nav' }, (props.sections || []).map(function (sec) {
        return h('div', { key: sec.title, className: 'bsm-sidebar-sec' },
          h('p', { className: 'bsm-overline bsm-sidebar-title' }, sec.title),
          h('ul', null, sec.items.map(function (it) {
            var active = props.active === it.label;
            return h('li', { key: it.label }, h('a', { href: '#', className: cx('bsm-navitem', active && 'is-active'), 'aria-current': active ? 'page' : undefined },
              h(Icon, { name: it.icon, size: 20 }), h('span', null, it.label),
              it.count != null ? h('span', { className: 'bsm-navitem-count' }, it.count) : null));
          })));
      })),
      props.user ? h('div', { className: 'bsm-sidebar-user' },
        h(Avatar, { name: props.user.name, size: 40 }),
        h('div', { className: 'bsm-sidebar-who' }, h('strong', null, props.user.name), h('span', null, props.user.role)),
        h(IconButton, { icon: 'log-out', label: 'Cerrar sesión', size: 'sm' })) : null);
  }
  function Topbar(props) {
    return h('header', { className: 'bsm-topbar' },
      props.compact ? h(IconButton, { icon: 'menu', label: 'Abrir menú' }) : null,
      props.title ? h('h1', { className: 'bsm-topbar-title' }, props.title) : null,
      h('label', { className: 'bsm-search' },
        h(Icon, { name: 'search', size: 18 }),
        h('input', { type: 'search', placeholder: props.placeholder || 'Buscar clientes, citas o módulos', 'aria-label': 'Buscar' }),
        props.compact ? null : h('kbd', null, 'Ctrl K')),
      h('div', { className: 'bsm-topbar-actions' },
        h(Tabs, { variant: 'segmented', className: 'bsm-theme-toggle', label: 'Tema', value: props.theme || 'light', items: [{ value: 'light', label: '', icon: 'sun' }, { value: 'dark', label: '', icon: 'moon' }] }),
        h(IconButton, { icon: 'bell', label: 'Notificaciones', badge: props.unread }),
        props.compact ? null : h(IconButton, { icon: 'log-out', label: 'Cerrar sesión' })));
  }
  function BottomNav(props) {
    var items = props.items || [{ icon: 'house', label: 'Inicio' }, { icon: 'calendar-plus', label: 'Reservar' }, { icon: 'calendar-days', label: 'Mis citas' }, { icon: 'user-round', label: 'Perfil' }];
    return h('nav', { className: cx('bsm-bottomnav', props.floating && 'is-floating'), 'aria-label': 'Navegación' },
      items.map(function (it) {
        var active = props.active === it.label;
        return h('a', { key: it.label, href: '#', className: cx('bsm-bottomnav-item', active && 'is-active'), 'aria-current': active ? 'page' : undefined },
          h('span', { className: 'bsm-bottomnav-pill' }, h(Icon, { name: it.icon, size: 24 }), it.badge ? h('span', { className: 'bsm-iconbtn-dot' }) : null),
          h('span', { className: 'bsm-bottomnav-label' }, it.label));
      }));
  }

  /* ---------- Agenda ---------- */
  function AgendaBoard(props) {
    var start = parseHM(props.start || '09:00'), end = parseHM(props.end || '20:00');
    var pxPerMin = props.pxPerMin || 1.2;
    var hours = [];
    for (var t = start; t <= end; t += 60) hours.push(t);
    var height = (end - start) * pxPerMin;
    var now = props.now != null ? parseHM(props.now) : null;
    return h('div', { className: 'bsm-agenda', style: { '--cols': props.barbers.length } },
      h('div', { className: 'bsm-agenda-head' },
        h('span', { className: 'bsm-agenda-corner' }),
        props.barbers.map(function (b) {
          return h('div', { key: b.name, className: cx('bsm-agenda-barber', b.current && 'is-current') }, b.avatar === false ? null : h(Avatar, { name: b.name, src: b.photo, size: 32 }),
            h('span', null, h('strong', null, b.name), h('span', { className: 'bsm-meta' }, b.sub != null ? b.sub : b.count + ' citas')));
        })),
      h('div', { className: 'bsm-agenda-body', style: { height: height } },
        h('div', { className: 'bsm-agenda-axis' }, hours.map(function (t) {
          return h('span', { key: t, style: { top: (t - start) * pxPerMin } }, formatTime(t).replace(':00', ''));
        })),
        h('div', { className: 'bsm-agenda-cols' },
          hours.map(function (t) { return h('span', { key: 'l' + t, className: 'bsm-agenda-hline', style: { top: (t - start) * pxPerMin } }); }),
          props.barbers.map(function (b, ci) {
            return h('div', { key: b.name, className: 'bsm-agenda-col' }, (b.items || []).map(function (a, i) {
              var s = parseHM(a.start), e = parseHM(a.end);
              var st = a.block ? null : (STATUS[a.status] || STATUS.Pendiente);
              var cls = a.block ? 'bsm-agenda-item is-block' : cx('bsm-agenda-item', 'bsm-status-' + st.key);
              var short = (e - s) * pxPerMin < 44;
              return h(a.href ? 'a' : 'button', { key: i, type: a.href ? undefined : 'button', href: a.href, className: cx(cls, short && 'is-short', a.selected && 'is-selected'), style: { top: (s - start) * pxPerMin + 1, height: (e - s) * pxPerMin - 2 },
                'aria-label': a.block ? 'Bloqueado ' + formatTime(s) + ' a ' + formatTime(e) + (a.client ? ', ' + a.client : '') : a.client + ', ' + a.service + ', ' + formatTime(s) + ' a ' + formatTime(e) + ', ' + st.label },
                h('span', { className: 'bsm-agenda-item-top' },
                  h('strong', null, a.block ? (a.client || 'Bloqueado') : a.client),
                  st ? h(Icon, { name: st.icon, size: 14, strokeWidth: 2.25 }) : h(Icon, { name: 'lock', size: 14 })),
                short ? null : h('span', { className: 'bsm-agenda-item-sub' }, (a.service ? a.service + ' · ' : '') + formatTime(s, true) + '–' + formatTime(e, true)));
            }));
          }),
          now != null && now >= start && now <= end ? h('div', { className: 'bsm-agenda-now', style: { top: (now - start) * pxPerMin } }, h('span', null, formatTime(now))) : null)));
  }

  var api = {
    Logo: Logo, Icon: Icon, Button: Button, IconButton: IconButton, Input: Input, Select: Select, Switch: Switch, Chip: Chip,
    StatusBadge: StatusBadge, Badge: Badge, Rating: Rating, Avatar: Avatar, ServiceCard: ServiceCard, BarberCard: BarberCard,
    AppointmentCard: AppointmentCard, StatCard: StatCard, Stepper: Stepper, Calendar: Calendar, SlotGrid: SlotGrid, Countdown: Countdown,
    Tabs: Tabs, Table: Table, Pagination: Pagination, Modal: Modal, ConfirmDialog: ConfirmDialog, Toast: Toast, Banner: Banner,
    Skeleton: Skeleton, EmptyState: EmptyState, Sidebar: Sidebar, Topbar: Topbar, BottomNav: BottomNav, AgendaBoard: AgendaBoard,
    format: { cop: formatCOP, time: formatTime, duration: formatDuration, initials: initials },
    STATUS: STATUS, SERVICE_ICON: SERVICE_ICON, ICON_NAMES: Object.keys(ICONS)
  };
  window.BSM = Object.assign(window.BSM || {}, api);
})();
