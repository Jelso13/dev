import subprocess
import json
from datetime import datetime, timezone
import re
import sys

# ==========================================
# 1. CONFIGURATION
# ==========================================
COLORS = {
    "work": "#3F566F",
    "development": "#637252",
    "personal": "#BC7101",
    "inactive": "#575757",
    "overdue": "#7A2F2F",
    "background": "#1C1A18",
    "text": "#E8E1D4"
}

try:
    BAR_WIDTH = int(sys.argv[1]) if len(sys.argv) > 1 else 60
except ValueError:
    BAR_WIDTH = 60

DEFAULT_ESTIMATE = 7200 

# ==========================================
# 2. DATA RETRIEVAL
# ==========================================
def run_cmd(cmd):
    try:
        output = subprocess.getoutput(cmd)
        start = output.find('[')
        end = output.rfind(']') + 1
        if start != -1 and end != -1:
            return json.loads(output[start:end])
    except Exception:
        pass
    return []

def get_timew_active():
    tw_data = run_cmd("timew export")
    return next((entry for entry in reversed(tw_data) if 'end' not in entry), None)

def get_task_active():
    task_data = run_cmd("task +ACTIVE export")
    if task_data:
        return task_data[0], True
    
    fallback_data = run_cmd("task $(task current +PENDING limit:1 | awk 'NR==4{print $1}') export")
    if fallback_data:
        return fallback_data[0], False
        
    return None, False

# ==========================================
# 3. LOGIC & STATE
# ==========================================
def parse_dt(dt_str):
    if not dt_str: return None
    return datetime.strptime(dt_str, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc)

def format_duration(seconds):
    h = int(seconds // 3600)
    m = int((seconds % 3600) // 60)
    s = int(seconds % 60)
    return f"{h:02d}:{m:02d}:{s:02d}"

def parse_iso_duration(duration_str):
    if not duration_str or not isinstance(duration_str, str) or not duration_str.startswith('P'):
        return 0
    pattern = re.compile(
        r'^P(?:(?P<weeks>\d+)W)?(?:(?P<days>\d+)D)?(?:T(?:(?P<hours>\d+)H)?(?:(?P<minutes>\d+)M)?(?:(?P<seconds>\d+)S)?)?$'
    )
    match = pattern.match(duration_str.upper())
    if not match: return 0
    parts = match.groupdict(default='0')
    return float(
        (int(parts['weeks']) * 604800) + 
        (int(parts['days']) * 86400) + 
        (int(parts['hours']) * 3600) + 
        (int(parts['minutes']) * 60) + int(parts['seconds'])
    )

def get_time_info(tw, task):
    now = datetime.now(timezone.utc)
    elapsed = 0
    
    if task and 'time_spent' in task:
        raw_spent = task['time_spent']
        if isinstance(raw_spent, str) and raw_spent.startswith('P'):
            elapsed += parse_iso_duration(raw_spent)
        else:
            try: elapsed += float(raw_spent)
            except ValueError: pass

    if tw and 'start' in tw:
        elapsed += (now - parse_dt(tw['start'])).total_seconds()
    elif task and 'start' in task:
        elapsed += (now - parse_dt(task['start'])).total_seconds()
        
    estimate = DEFAULT_ESTIMATE
    if task and 'estimate' in task:
        raw_estimate = task['estimate']
        if isinstance(raw_estimate, str) and raw_estimate.startswith('P'):
            estimate = parse_iso_duration(raw_estimate)
        else:
            try: estimate = float(raw_estimate)
            except ValueError: pass
                
    return elapsed, estimate

def determine_category(task, tw):
    tags = []
    if task and 'tags' in task: tags.extend(task['tags'])
    if tw and 'tags' in tw: tags.extend(tw['tags'])

    for t in ["work", "development", "personal"]:
        if t in tags: return t
    return "misc"

# ==========================================
# 4. UI BUILDERS
# ==========================================
def build_progress_bar(base_color, has_tw, is_active, elapsed, estimate, desc):
    
    # 1. Format Time String (Right Aligned)
    if elapsed > estimate and estimate > 0:
        time_text = f"{format_duration(elapsed)} / {format_duration(estimate)} (+{format_duration(elapsed - estimate)}) "
    else:
        time_text = f"{format_duration(elapsed)} / {format_duration(estimate)} "

    # Allow description to fill the space up to the time text
    max_desc = BAR_WIDTH - len(time_text) - 2
    if len(desc) > max_desc:
        desc = desc[:max_desc-3] + "..."

    char_array = [" "] * BAR_WIDTH

    # Insert Time on the Right
    for i, char in enumerate(time_text):
        char_array[BAR_WIDTH - len(time_text) + i] = char

    # Insert Title on the LEFT side of the progress bar (Matches SVG)
    # Adding one space of padding so it breathes naturally next to the Tag gap
    desc_padded = " " + desc
    for i, char in enumerate(desc_padded):
        if i < len(char_array) - len(time_text):
            char_array[i] = char

    full_string = "".join(char_array)

    # Calculate Percentage and Slice
    progress_ratio = min(elapsed / estimate, 1.0) if estimate > 0 else 0
    filled_chars = int(BAR_WIDTH * progress_ratio)

    filled_text = full_string[:filled_chars]
    empty_text = full_string[filled_chars:]

    # Apply Colors
    filled_bg = base_color if (has_tw or is_active) else base_color
    empty_bg = "#333333"
    text_color = COLORS["background"] if has_tw else COLORS["text"]

    return f"%{{B{filled_bg}}}%{{F{text_color}}}{filled_text}%{{B{empty_bg}}}%{{F{COLORS['text']}}}{empty_text}%{{B-}}%{{F-}}"

# ==========================================
# 5. MAIN EXECUTION
# ==========================================
def main():
    tw = get_timew_active()
    task, is_active = get_task_active()
    
    has_tw = bool(tw)
    overdue = False
    if task and 'due' in task:
        due_dt = parse_dt(task['due'])
        overdue = datetime.now(timezone.utc) > due_dt

    task_id = task.get('id', '?') if task else '?'
    category = determine_category(task, tw)
    elapsed, estimate = get_time_info(tw, task)
    desc = task['description'] if task else "Ready."

    if not is_active and not has_tw:
        base_color = COLORS["overdue"] if overdue else COLORS["inactive"]
        label_text = f"ID: {task_id}"
    else:
        base_color = COLORS["overdue"] if overdue else COLORS.get(category, COLORS["misc"])
        label_text = category.upper() if has_tw else f"ID: {task_id}"

    # Notice the %{B-} was removed from the end of this string so the color bleeds seamlessly
    tag_block = f"%{{B{base_color}}} %{{T2}}󰖟 %{{T-}}{label_text} "
    
    progress_bar = build_progress_bar(base_color, has_tw, is_active, elapsed, estimate, desc)

    # OUTPUT: No spaces between the blocks!
    print(f"{tag_block}{progress_bar}")

if __name__ == "__main__":
    main()
