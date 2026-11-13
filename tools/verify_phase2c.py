#!/usr/bin/env python3
"""Isolated verification; rendered processes share one locked display and run sequentially."""
import concurrent.futures,fcntl,json,os,pathlib,subprocess,sys,re
ROOT=pathlib.Path(__file__).resolve().parents[1]
LOGS=ROOT/'docs/review/phase2c/logs';LOGS.mkdir(parents=True,exist_ok=True)
base=os.environ.copy();base.update(DISPLAY=':99',XDG_CONFIG_HOME='/workspace/.runtime/config',XDG_CACHE_HOME='/workspace/.runtime/cache')
def run(item,render=False):
 name,script,args=item;env=base.copy();env['XDG_DATA_HOME']='/workspace/.runtime/phase2c-rendered-regressions' if render else '/workspace/.runtime/phase2c-'+name
 command=['godot']+(['--audio-driver','Dummy'] if render else ['--headless'])+['--path',str(ROOT),'--script','res://tests/'+script+'.gd']
 if '--stories' in sys.argv: env['XDG_DATA_HOME']='/workspace/.runtime/phase2c-stories'
 if args: command+=['--']+args
 with (LOGS/(name+'.log')).open('w') as log:
  try: code=subprocess.run(command,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=1500).returncode
  except subprocess.TimeoutExpired: code=124
 text=(LOGS/(name+".log")).read_text()
 if code==0 and ("SCRIPT ERROR" in text or "FAIL " in text or not re.search(r"[A-Z ]+: \d+/\d+",text)): code=1
 print(name,code,flush=True);return name,code
if '--headless' in sys.argv:
 names=['save_contract','style_contract','pairs_contract','session_contract','phase1d_ui_contract','phase1d_room_contract','phase1d_save_contract','home_rules_contract','home_session_contract','home_navigation_contract','home_layout_contract','neighborhood_rules_contract','neighborhood_session_contract','neighbor_navigation_contract']
 if '--include-new' in sys.argv: names+=['cozy_story_contract','cozy_life_session_contract']
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: results=dict(pool.map(run,[(n,n,[]) for n in names]))
else:
 lock=open('/tmp/dream-render-verification.lock','w');fcntl.flock(lock,fcntl.LOCK_EX)
 runs=[('phase_one','phase_one',[]),('phase1c_fresh','phase1c_flow',[]),('phase1c_legacy','phase1c_flow',['--legacy']),('ui_focus','ui_focus',[]),('phase1d_flow','phase1d_flow',[]),('phase1d_continue','phase1d_flow',['--resume']),('phase2a_flow','phase2a_flow',[]),('phase2a_continue','phase2a_flow',['--resume']),('phase2a_recipes','phase2a_recipes',[]),('phase2a_effects','phase2a_effects',[]),('phase2b_flow','phase2b_flow',[]),('phase2b_continue','phase2b_flow',['--resume']),('phase2b_social','phase2b_social_flow',[]),('phase2b_social_continue','phase2b_social_flow',['--resume']),('phase2b_camera','phase2b_camera',[]),('phase2b_capture','phase2b_capture',[])]
 if '--stories' in sys.argv: runs=[('phase2c_flow','phase2c_flow',[]),('phase2c_continue','phase2c_flow',['--resume']),('phase2c_review','phase2c_review',[]),('phase2c_review_continue','phase2c_review',['--resume'])]
 results={}
 if "--from" in sys.argv:
  target=sys.argv[sys.argv.index("--from")+1]
  runs=runs[next(i for i,item in enumerate(runs) if item[0]==target):]
  prior=LOGS/"rendered_exits.json"
  if prior.exists(): results=json.loads(prior.read_text())
 for item in runs:
  name,code=run(item,True);results[name]=code
  if code: break
(LOGS/('headless_exits.json' if '--headless' in sys.argv else 'journey_exits.json' if '--stories' in sys.argv else 'rendered_exits.json')).write_text(json.dumps(results,indent=2)+'\n')
sys.exit(0 if all(code==0 for code in results.values()) else 1)
