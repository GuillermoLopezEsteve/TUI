// Package i18n holds the Catalan strings shown in LabCheck's UI, per the
// language requirement in requirments/00-overview.md.
package i18n

const (
	AppName = "LabCheck"

	StudentLabel = "Estudiant"
	StudentUnset = "sense definir"

	SetStudentTitle   = "Introdueix el número d'estudiant"
	NumberPromptLabel = "Número [1–100]:"
	InvalidNumber     = "Cal un número enter entre 1 i 100."

	HelpStudentFirstLaunch = "Enter desa   Esc surt"
	HelpStudentModal       = "Enter desa   C cancel·la   Esc surt"

	ActivitiesTitle = "Activitats"
	HelpActivities  = "↑/↓ mou   Enter obre   U estudiant   Esc/Ctrl+C surt"
	NoActivities    = "No s'ha trobat cap activitat a %s"

	TestPassed  = "PROVA SUPERADA"
	NotSelected = "Cap prova seleccionada."

	HelpActivity = "Enter executa   a executa secció   t veure script   U estudiant   C enrere   Esc/Ctrl+C surt"

	ScriptPopupTitle = "Script de la prova"
	HelpScriptPopup  = "↑/↓ desplaça   t/C tanca"

	RunningLabel = "en curs…"
	BatchBusy    = "Ja s'està executant una prova."
)
