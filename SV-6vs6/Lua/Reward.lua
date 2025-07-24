-- รับโบนัสความน่าจะเป็นของสัตว์ประหลาด
function getNpcExtraRatio(npczone)
  local curtime = os.time()
  local ratio = 1

  -- สัตว์ประหลาดหอคอยอินฟินิตี้
  if npczone == ENPCZONE_ENDLESSTOWER then
    local starttab = {year=2015, month=7, day=1, hour=0, min=0}
    local endtab = {year=2015, month=9, day=1, hour=0, min=0}

    local starttime = os.time(starttab)
    local endtime = os.time(endtab)
    if curtime > starttime and curtime < endtime then
      ratio = 4
    end
  end

  return ratio
end

-- รับโบนัสความน่าจะเป็นของแผนที่
function getMapExtraRatio(npc)
  local curtime = os.time()
  local ratio = 1
  local mapid = npc:getMapID()
  
  -- กิจกรรมหนีผี
  if mapid == 8 or mapid == 9 then
    local starttab = {year=2016, month=10, day=30, hour=0, min=0}
    local endtab = {year=2016, month=11, day=1, hour=23, min=59}

    local starttime = os.time(starttab)
    local endtime = os.time(endtab)
    if curtime > starttime and curtime < endtime then
      if npc:getNpcID()== 10019 or npc:getNpcID()== 10020 or npc:getNpcID()== 10022 or npc:getNpcID()== 20004 or npc:getNpcID()==30004 then
        ratio = 5
      end
    end
  end

  return ratio
end

-- การคำนวณความน่าจะเป็นของหอคอยอนันต์
function calcTowerRewardRatio(npctype, zonetype)

  -- รับโบนัส NPC
  local ratio = getNpcExtraRatio(zonetype)

  -- miniboss和mvp ลดค่าสัมประสิทธิ์
  if npctype == ENPCTYPE_MINIBOSS then
    return ratio * 1
  end
  
  if npctype == ENPCTYPE_MVP then
    return ratio * 1
  end
  
  return ratio
end

-- การคำนวณความน่าจะเป็นของสัตว์ประหลาดในป่า
-- ismvp:มันเป็นอัตราการดรอป MVP พิเศษหรือเปล่า?
function calcMapRewardRatio(npc, user, isquest, ismvp)   --任务表中的reward不受影响
  if isquest == true then
    return 1
  end
  
  if npc == nil or user == nil then
    return 2
  end
  
  if npc:getNpcZoneType() == ENPCZONE_TASK then   --任务怪的掉落reward不受影响
    return 1
  end
  -- การดรอปจากมอนสเตอร์หญ้าจะไม่ได้รับผลกระทบจากระยะเวลาการต่อสู้และความแตกต่างของเลเวล
  if npc:getNpcID() >= 40001 and npc:getNpcID() <= 49999 then
    return 1
  end
  -- --ดรอปแมนดาลากรีดร้องจะไม่ได้รับผลกระทบจากระยะเวลาการต่อสู้หรือความแตกต่างของระดับ
  -- if npc:getNpcID() >= 17000 and npc:getNpcID() <= 17002 then
  --   return 1
  -- end
  --การปล่อยแมวเซลล์ B จะไม่ได้รับผลกระทบจากระยะเวลาการต่อสู้และความแตกต่างของระดับ
  if npc:getNpcID() >= 10107 and npc:getNpcID() <= 10116 then
    return 1
  end
  
  local ratio = getMapExtraRatio(npc)

  if npc:getNpcType() == ENPCTYPE_MINIBOSS or npc:getNpcType() == ENPCTYPE_MVP then
    return ratio * 2
  end

  if ismvp then 
    return ratio
  end

  local newratio = ratio * user:getTeamAddictRatio()

  local deltalv = npc:getLevel() - user:getLevel()
  local star = npc:isStarMonster()

  if user.getKillCount ~= nil and npc.getPeriodCnt ~= nil then
    local killcnt = user:getKillCount(npc:getNpcID())
    local normalcnt = npc:getPeriodCnt()
    if killcnt ~= 0 and normalcnt ~= 0 and killcnt > normalcnt then
      newratio = normalcnt / killcnt * newratio
    end

    if killcnt ~= 0 and normalcnt == 0 and npc:getNpcZoneType() == ENPCZONE_FIELD then
      local begintime = 1527782400 -- การสลายครั้งใหม่จะเริ่มในวันที่ 1 มิถุนายน
      local curtime = os.time()
      local newnormalcnt = 44 -- ตัวเลข ณ วันที่ 28 มีนาคม
      if curtime > begintime then
        newnormalcnt = 44 - (curtime - begintime) / 86400 * 11 / 28 -- ลดลงจาก 44 เป็น 33 ใน 4 สัปดาห์ ลดลง 11/28 ทุกวัน
        if newnormalcnt < 33 then
          newnormalcnt = 33
        end
      end

      if killcnt > newnormalcnt then
        newratio = newnormalcnt / killcnt * newratio
      end
    end
  end

  return newratio * CommonFun.getItemReduceValue(deltalv, star)
end

-- การคำนวณความน่าจะเป็นของมอนสเตอร์ที่ถูกปิดผนึก
function calcSealRewardRatio(membercount)
  return membercount / 1
end

-- คำนวณอัตราการสลายตัวของการติดยาเสพติด
function calcAddictRatio(user, usedtime, exclude_skill)
  if user == nil then
    return 0
  end
  local ratio = 1
  local totaltime = user:getTotalBattleTime()

  if usedtime <= totaltime then
    local Advance = 1
    local TeamPros = 0
      
    if exclude_skill ~= true and user:isSkillEnable(50045001) then  
        local TeamNum = user:getMapTeamPros()
        if TeamNum >=5 then
          TeamPros = 0.20
        elseif TeamNum ==4 then
          TeamPros = 0.15
        elseif TeamNum ==3 then
          TeamPros = 0.10
        end
    end
  
     Advance = user:getNormalDrop(Advance + TeamPros)
     return ratio * Advance
  end

  local stage = CommonFun.getAddictStage()
  if stage == 0 then
    return ratio
  end

  ratio = 1 - (usedtime - totaltime) / stage * 0.95
  if ratio < 0.05 then
    return 0.05
  end

  return ratio
end

-- ปรับค่าประสบการณ์การ
function calcAddictDropExp(user,sec, exp)
  -- ค่าประสบการณ์ไม่ได้รับผลกระทบจากการล่าแบบร่วมมือ
  local newexp = calcAddictRatio(user, sec, true) * exp * 5
  return newexp
end

-- คำนวณปริมาณที่ละลาย
function calcDecomposeResult(param)
  if param >= 500 and param <= 750 then
    return 2
  elseif param >= 800 and param <= 1200 then
    return 3
  elseif param >= 1250 and param <= 1450 then
    return 4
  elseif param >= 1500 then
    return 5
  end

  return 1
end
function calcDecomposeFloatParam(showtype)
  if showtype == 1 then
    return 0.5
  end
  if showtype == 2 then
    return 1.5
  end

  math.randomseed(os.time())
  local r = math.random(0, 1660)
  if r <= 20 then
    return 0.5
  elseif r <= 60 then
    return 0.55
  elseif r <= 120 then
    return 0.6
  elseif r <= 200 then
    return 0.65
  elseif r <= 290 then
    return 0.7
  elseif r <= 380 then
    return 0.75
  elseif r <= 480 then
    return 0.8
  elseif r <= 580 then
    return 0.85
  elseif r <= 680 then
    return 0.9
  elseif r <= 780 then
    return 0.95
  elseif r <= 880 then
    return 1
  elseif r <= 980 then
    return 1.05
  elseif r <= 1080 then
    return 1.1
  elseif r <= 1180 then
    return 1.15
  elseif r <= 1280 then
    return 1.2
  elseif r <= 1370 then
    return 1.25
  elseif r <= 1460 then
    return 1.3
  elseif r <= 1540 then
    return 1.35
  elseif r <= 1600 then
    return 1.4
  elseif r <= 1640 then
    return 1.45
  elseif r <= 1660 then
    return 1.5
  end
  return 0
end

function getRefineParam(refinelv)
  local refineparam = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
    [4] = 1,
    [5] = 1.2,
    [6] = 1.4,
    [7] = 1.6,
    [8] = 2.2,
    [9] = 3.4,
    [10] = 5,
    [11] = 7.4,
    [12] = 12.4,
    [13] = 19.8,
    [14] = 35.2,
    [15] = 57.4
  }
  if refineparam[refinelv] == nil then
    return 1
  end

  return refineparam[refinelv]
end
function calcDecomposeCount(user, decomposenum, decomposeorinum, mtotalprice, metalrate, metalprice, refinelv, floatparam)
  if user == nil then
    return 0
  end

  local refineparam = getRefineParam(refinelv)
  if metalprice == 0 or floatparam == 0 then
    --print("metalprice="..metalprice.." floatparam="..floatparam)
    return 0
  end

  --print("decomposenum="..decomposenum) ค่าโลหะของอุปกรณ์
  --print("decomposeorinum="..decomposeorinum) 原始数量
  --print("mtotalprice="..mtotalprice) ปริมาณเดิม
  --print("metalrate="..metalrate)ความน่าจะเป็นของโลหะ
  --print("refinelv="..refinelv) ระดับการกลั่น
  --print("metalprice="..metalprice) โลหะราคาถูก
  --print("floatparam="..floatparam) ค่าสัมประสิทธิ์ลอยตัว
  --print("refineparam="..refineparam) ค่าสัมประสิทธิ์การกลั่น
  --print("------------------------")
  local basecnt = decomposenum * metalrate / metalprice * floatparam * refineparam
  local userentry = Entry.new(user) -- ServerLua : Entry
  local metalparam = CommonFun.calcOrideconResearch(userentry)

  return basecnt * (1 + metalparam)
end

