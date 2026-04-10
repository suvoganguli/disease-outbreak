from pathlib import Path
from datetime import datetime

# =========================================================
# PATHS
# =========================================================
BASE_DIR = Path(__file__).resolve().parent

PATHS = {
    "data_raw": BASE_DIR / "data" / "raw",
    "data_interim": BASE_DIR / "data" / "interim",
    "data_processed": BASE_DIR / "data" / "processed",
    "notebooks": BASE_DIR / "notebooks",
    "src": BASE_DIR / "src",
    "scripts": BASE_DIR / "scripts",
    "figures": BASE_DIR / "outputs" / "figures",
    "tables": BASE_DIR / "outputs" / "tables",
    "models": BASE_DIR / "outputs" / "models",
}

# =========================================================
# PROJECT / DISEASE SETTINGS
# =========================================================
DISEASES = ["flu", "dengue", "cholera"]

DEFAULT_DISEASE = "flu"
DEFAULT_REGION = "illinois"

# Forecast horizons to evaluate later in modeling notebooks
FORECAST_HORIZONS = [1, 2, 3, 4]

# Default lag features to create later in modeling notebooks
DEFAULT_LAGS = [1, 2, 3, 4]

# Default outbreak labeling options for later
DEFAULT_OUTBREAK_QUANTILE = 0.85

# Plot / output defaults
SAVEFIG_DPI = 300
SAVE_PARQUET_INDEX = False
SAVE_CSV_INDEX = False

# =========================================================
# FILE REGISTRY
# =========================================================
FILES = {
    # -------------------------
    # Flu raw inputs
    # -------------------------
    "flu_raw_json": PATHS["data_raw"] / "flu" / "fluview_il_201040_202652.json",
    "flu_weather_raw_json": PATHS["data_raw"] / "flu" / "weather_openmeteo_springfield_il_2010-10-01_2026-04-10.json",

    # -------------------------
    # Flu interim tables
    # -------------------------
    "flu_weekly_disease": PATHS["data_interim"] / "flu" / "flu_weekly_disease.parquet",
    "flu_daily_weather": PATHS["data_interim"] / "flu" / "flu_daily_weather.parquet",
    "flu_weekly_weather": PATHS["data_interim"] / "flu" / "flu_weekly_weather.parquet",

    # -------------------------
    # Flu processed base table
    # -------------------------
    "flu_weekly_merged_parquet": PATHS["data_processed"] / "flu" / "flu_weekly_merged.parquet",
    "flu_weekly_merged_csv": PATHS["data_processed"] / "flu" / "flu_weekly_merged.csv",
}

# =========================================================
# HELPERS
# =========================================================
def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def ensure_project_dirs() -> None:
    # Main project folders
    for p in PATHS.values():
        ensure_dir(p)

    # Disease-specific folders
    for disease in DISEASES:
        ensure_dir(PATHS["data_raw"] / disease)
        ensure_dir(PATHS["data_interim"] / disease)
        ensure_dir(PATHS["data_processed"] / disease)
        ensure_dir(PATHS["figures"] / disease)

    ensure_dir(PATHS["tables"])
    ensure_dir(PATHS["models"])


def timestamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def savefig(fig, filename: str, subdir: str | None = None, dpi: int = SAVEFIG_DPI):
    """
    Save a matplotlib figure into outputs/figures or a disease-specific subfolder.

    Examples
    --------
    savefig(fig, "flu_wili_over_time.png")
    savefig(fig, "flu_wili_over_time.png", subdir="flu")
    """
    out_dir = PATHS["figures"] if subdir is None else PATHS["figures"] / subdir
    ensure_dir(out_dir)
    path = out_dir / filename
    fig.savefig(path, dpi=dpi, bbox_inches="tight")
    print(f"Saved figure: {path}")
    return path


def save_parquet(df, path: Path, index: bool = SAVE_PARQUET_INDEX):
    ensure_dir(path.parent)
    df.to_parquet(path, index=index)
    print(f"Saved parquet: {path}")
    return path


def save_csv(df, path: Path, index: bool = SAVE_CSV_INDEX):
    ensure_dir(path.parent)
    df.to_csv(path, index=index)
    print(f"Saved csv: {path}")
    return path


def print_config_summary():
    print("===== CONFIG SUMMARY =====")
    print(f"Base Dir: {BASE_DIR}")
    print(f"Default Disease: {DEFAULT_DISEASE}")
    print(f"Default Region: {DEFAULT_REGION}")
    print(f"Forecast Horizons: {FORECAST_HORIZONS}")
    print(f"Default Lags: {DEFAULT_LAGS}")
    print(f"Default Outbreak Quantile: {DEFAULT_OUTBREAK_QUANTILE}")
    print(f"Raw Data Dir: {PATHS['data_raw']}")
    print(f"Interim Data Dir: {PATHS['data_interim']}")
    print(f"Processed Data Dir: {PATHS['data_processed']}")
    print(f"Figures Dir: {PATHS['figures']}")
    print(f"Tables Dir: {PATHS['tables']}")
    print(f"Models Dir: {PATHS['models']}")
    print(f"Flu Raw JSON: {FILES['flu_raw_json']}")
    print(f"Flu Weather Raw JSON: {FILES['flu_weather_raw_json']}")


# Create directories on import so notebooks work smoothly
ensure_project_dirs()
