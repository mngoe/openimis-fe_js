import { createTheme } from "@material-ui/core";
import { alpha } from "@material-ui/core/styles/colorManipulator";

const theme = createTheme({
  overrides: {
    MuiTableRow: {
      root: {
        "&$selected": {
          backgroundColor: "rgba(0, 0, 0, 0.08)",
        },
      },
    },
  },
  palette: {
    primary: { main: "#004A7C" },
    secondary: { main: "#fff" },
    error: { main: "#801a00" },
    text: {
      primary: "#004A7C",
      secondary: "#004A7C",
      second: "#fff",
      error: "#801a00",
    },
    toggledButton: "#999999",
  },
  typography: {
    useNextVariants: true,
    fontFamily: ["Rubik", "Roboto", '"Helvetica Neue"', "sans-serif"].join(","),
    fontSize: 14,
    fontWeightRegular: 300,
    fontWeightMedium: 400,
    title: {
      fontSize: 20,
      fontWeight: 300,
    },
    label: {
      color: "grey",
    },
  },
  jrnlDrawer: {
    open: {
      width: 500,
    },
    close: {
      width: 80,
    },
    itemDetail: {
      marginLeft: 8,
    },
    iconSize: 24,
  },
  menu: {
    variant: "AppBar",
    drawer: {
      width: 300,
      fontSize: 16,
      backgroundColor:"#004A7C"
    },
    appBar: {
      fontSize: 16,
    },
  },
  page: {
    padding: 16,
    locked: {
      background: "repeating-linear-gradient(45deg, #D3D3D3 1px, #D3D3D3 1px, #fff 10px, #fff 10px);",
    },
  },
  paper: {
    paper: {
      margin: 10,
      backgroundColor: "#DEF1EE", // anciennement #dbeef0
    },
    header: {
      color: "#004A7C",
      backgroundColor: "#37D4CC", // anciennement #b7d4d8
    },
    message: {
      backgroundColor: "#37D4CC", // anciennement #b7d4d8
    },
    title: {
      padding: 10,
      fontSize: 24,
      color: "#004A7C",
      backgroundColor: "#37D4CC", // anciennement #b7d4d8
    },
    action: {
      padding: 5,
    },
    divider: {
      padding: 0,
      margin: 0,
    },
    body: {
      marginTop: 10,
      backgroundColor: "#DEF1EE", // anciennement #dbeef0
    },
    item: {
      padding: 10,
    },
  },
  table: {
    title: {
      padding: 10,
      fontWeight: 500,
      color: "#004A7C",
      backgroundColor: "#37D4CC", // anciennement #b7d4d8
    },
    header: {
      color: "#004A7C",
    },
    headerAction: {
      padding: 5,
    },
    row: {
      color: "#004A7C",
      align: "center",
      "&:hover": {
        background: "rgba(0, 0, 0, 0.12) !important",
      },
    },
    cell: {
      padding: 5,
    },
    lockedRow: {
      background: "repeating-linear-gradient(45deg, #D3D3D3 1px, #D3D3D3 1px, #fff 10px, #fff 10px);",
    },
    lockedCell: {},
    highlightedRow: {},
    highlightedCell: {
      fontWeight: 500,
      align: "center",
    },
    secondaryHighlightedRow: {
      backgroundColor: "#DEF1EE", // anciennement #cbedf2
    },
    secondaryHighlightedCell: {},
    highlightedAltRow: {},
    highlightedAltCell: {
      fontStyle: "italic",
      align: "center",
    },
    disabledRow: {},
    disabledCell: {
      color: "grey",
      align: "center",
    },
    footer: {
      color: "#004A7C",
    },
    pager: {
      color: "#004A7C",
    },
  },
  form: {
    spacing: 10,
  },
  formTable: {
    table: {
      color: "#004A7C",
    },
    actions: {
      color: "#004A7C",
    },
    header: {
      color: "#004A7C",
      align: "center",
    },
  },
  dialog: {
    title: {
      fontWeight: 500,
      color: "grey",
    },
    content: {
      padding: 0,
    },
    primaryButton: {
      backgroundColor: "#004A7C",
      color: "#fff",
      fontWeight: "bold",
      "&:hover": {
        backgroundColor: alpha("#004A7C", 0.5),
        color: "#004A7C",
      },
    },
    secondaryButton: {},
  },
  tooltipContainer: {
    position: 'fixed',
    bottom: 15,
    right: 8,
    zIndex: 2000,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-end',
  },
  flexTooltip: {
    marginBottom: 5,
  },
  fab: {
    position: "fixed",
    bottom: 20,
    right: 8,
    zIndex: 2000,
  },
  fakeInput: {},
  bigAvatar: {
    width: 160,
    height: 160,
  },
  buttonContainer: {
    horizontal: {
      display: "flex",
      flexWrap: "nowrap",
      overflowX: "auto",
      justifyContent: "flex-end",
    },
  },
});

export default theme;
