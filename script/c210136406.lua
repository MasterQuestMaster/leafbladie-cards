--Amazoness Colosseum
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.condition)
	c:RegisterEffect(e0)
    --Attacking monsters cannot be destroyed by battle
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.aclimit1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.aclimit2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1, 0)
	e4:SetCondition(s.econ1)
	e4:SetValue(s.elimit)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetOperation(s.aclimit3)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetOperation(s.aclimit4)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCondition(s.econ2)
	e7:SetTargetRange(0, 1)
	c:RegisterEffect(e7)
    --Destroy itself
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOGRAVE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(s.descon)
	e8:SetTarget(s.destg)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
end
s.listed_series={0x4}
--Activate
function s.condition(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
    return #g>0 and g:FilterCount(aux.FilterFaceupFunction(Card.IsSetCard, 0x4), nil)==#g
end
--Attacking monsters cannot be destroyed by battle
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a and a:IsFaceup() and a:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
--Activation limit
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if ep==1-tp or not (re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_ONFIELD and not rc:IsSetCard(0x4)) then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_CONTROL+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if ep~=tp or not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActivateLocation()==LOCATION_ONFIELD and not rc:IsSetCard(0x4)) then return end
	e:GetHandler():ResetFlagEffect(id)
end
function s.econ1(e)
	return e:GetHandler():GetFlagEffect(id)>=Duel.GetBattledCount(e:GetHandlerPlayer())
        and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.aclimit3(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if ep==tp or not (re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_ONFIELD and not rc:IsSetCard(0x4)) then return end
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_CONTROL+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit4(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if ep==tp or not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActivateLocation()==LOCATION_ONFIELD and not rc:IsSetCard(0x4)) then return end
	e:GetHandler():ResetFlagEffect(id+1)
end
function s.econ2(e)
	return e:GetHandler():GetFlagEffect(id+1)>=Duel.GetBattledCount(e:GetHandlerPlayer())
        and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.elimit(e, re, tp)
    local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0x4)
end
--
function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x4) and c:IsLevelAbove(6)
end
function s.descon(e, tp, eg, ep, ev, re, r, rp)
	return not Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(), REASON_EFFECT)
	end
end