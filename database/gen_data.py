"""Generates insert_data.sql (stations, trains, routes, schedules, seats, users, bookings). Run: python gen_data.py > insert_data.sql"""
import random, datetime
from werkzeug.security import generate_password_hash as gph
random.seed(7); out=[]; q=lambda s:"'"+str(s).replace("'","''")+"'"
def ins(t,cols,rows):
    for r in rows: out.append(f"INSERT INTO {t}({cols}) VALUES({','.join(q(x) if isinstance(x,str) else str(x) for x in r)});")
out.append("USE railway_db;")
S=[("HWH","Howrah Junction","Kolkata"),("SDAH","Sealdah","Kolkata"),("KGP","Kharagpur Junction","Kharagpur"),("PNBE","Patna Junction","Patna"),("BSB","Varanasi Junction","Varanasi"),("LKO","Lucknow Charbagh","Lucknow"),("NDLS","New Delhi","Delhi"),("MAS","Chennai Central","Chennai"),("SBC","KSR Bengaluru","Bengaluru"),("CSMT","Mumbai CSMT","Mumbai")]
ins("station","code,name,city",S); sid={s[0]:i+1 for i,s in enumerate(S)}
T=[("12301","Howrah Rajdhani","Rajdhani",[("HWH",0,"16:55"),("PNBE",531,"23:45"),("BSB",678,"01:30"),("NDLS",1447,"10:05")]),
("12302","New Delhi Rajdhani","Rajdhani",[("NDLS",0,"16:50"),("BSB",765,"23:30"),("PNBE",916,"02:10"),("HWH",1447,"10:00")]),
("12839","Howrah Chennai Mail","Mail",[("HWH",0,"23:35"),("KGP",116,"01:25"),("MAS",1660,"06:00")]),
("12509","Bengaluru Express","Express",[("MAS",0,"06:00"),("SBC",358,"11:30")]),
("12951","Mumbai Rajdhani","Rajdhani",[("NDLS",0,"16:35"),("CSMT",1384,"08:15")]),
("12345","Saraighat Express","Express",[("SDAH",0,"06:50"),("KGP",120,"08:55"),("LKO",1150,"22:40")])]
ins("train","train_no,name,train_type",[t[:3] for t in T])
rid=[]; 
for ti,t in enumerate(T,1):
    for i,(c,d,tm) in enumerate(t[3],1): ins("train_route","train_id,station_id,stop_seq,arr_time,dep_time,dist_km",[(ti,sid[c],i,tm+":00",tm+":00",d)])
cls=["SL","3A"]; cid=0; seats={}; sc=0
for ti in range(1,len(T)+1):
    for k,c in enumerate(cls,1):
        cid+=1; ins("coach","train_id,coach_no,class",[(ti,("S" if c=="SL" else "B")+str(k),c)]); seats[cid]=(ti,c)
        for n in range(1,9): sc+=1; ins("seat","coach_id,seat_no,berth",[(cid,n,["LOWER","MIDDLE","UPPER","SIDE"][n%4])])
seat_info={}; cur=0
for cid,(ti,c) in seats.items():
    for n in range(8): cur+=1; seat_info[cur]=(ti,c)
d0=datetime.date(2026,11,5); sched=[]
for ti in range(1,len(T)+1):
    for k in range(4): sched.append((ti,d0+datetime.timedelta(days=k*3+ti)))
ins("schedule","train_id,journey_date",[(a,str(b)) for a,b in sched])
for si,(ti,_) in enumerate(sched,1):
    for sid_,(t2,_) in seat_info.items():
        if t2==ti: out.append(f"INSERT INTO schedule_seat(schedule_id,seat_id) VALUES({si},{sid_});")
names=["Aarav Sen","Riya Das","Arjun Roy","Megha Paul","Ritwik Das","Aditi Sen","Sneha Ghosh","Rahul Dey","Priya Nair","Kabir Shah"]
ins("passenger","name,email,phone,password_hash,role",[("Admin","admin@rail.com","9000000000",gph("admin123"),"ADMIN")]+[(n,n.split()[0].lower()+"@mail.com","98"+str(random.randint(10**7,10**8-1)),gph("user123"),"USER") for n in names])
rate={"SL":0.6,"3A":1.6}; used=set(); pn=0
for b in range(1,31):
    si=random.randint(1,len(sched)); ti=sched[si-1][0]; stops=T[ti-1][3]
    i,j=sorted(random.sample(range(len(stops)),2)); fs,ts=stops[i],stops[j]
    free=[s for s,(t2,_) in seat_info.items() if t2==ti and (si,s) not in used]
    n=min(random.randint(1,2),len(free)); pick=random.sample(free,n); fares=[round((ts[1]-fs[1])*rate[seat_info[s][1]],2) for s in pick]
    pnr=str(random.randint(10**9,10**10-1)); ins("booking","pnr,passenger_id,schedule_id,from_station,to_station,total_fare",[(pnr,random.randint(2,11),si,sid[fs[0]],sid[ts[0]],sum(fares))])
    for s,f in zip(pick,fares): used.add((si,s)); ins("booking_passenger","booking_id,schedule_id,seat_id,name,age,gender,fare",[(b,si,s,random.choice(names),random.randint(8,70),random.choice("MFO"),f)])
    ins("payment","booking_id,amount,mode",[(b,sum(fares),random.choice(["UPI","CARD","NETBANKING"]))])
for b in (3,8,15): out.append(f"CALL cancel_ticket({b},'Change of plan');")
print("\n".join(out))
