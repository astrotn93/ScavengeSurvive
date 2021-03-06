static
	knockout_Tick[MAX_PLAYERS],
	knockout_Duration[MAX_PLAYERS];


KnockOutPlayer(playerid, duration)
{
	SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - knockout_Tick[playerid]);
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, 1000 * (40.0 - gPlayerHP[playerid]));
	ShowPlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
	{
		ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS", 4.0, 0, 1, 1, 1, 0, 1);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new vehicleid = GetPlayerVehicleID(playerid);

			switch(GetVehicleType(GetVehicleModel(vehicleid)))
			{
				case VTYPE_BIKE, VTYPE_QUAD, VTYPE_BMX:
				{
					new
						Float:x,
						Float:y,
						Float:z;

					GetVehiclePos(vehicleid, x, y, z);
					RemovePlayerFromVehicle(playerid);
					SetPlayerPos(playerid, x, y, z);
					ApplyAnimation(playerid, "PED", "BIKE_fall_off", 4.0, 0, 1, 1, 0, 0, 1);
				}

				default:
				{
					VehicleEngineState(vehicleid, 0);
				}
			}
		}
	}
	else
	{
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);
	}

	knockout_Tick[playerid] = tickcount();
	knockout_Duration[playerid] = duration;
	t:bPlayerGameSettings[playerid]<KnockedOut>;
}

WakeUpPlayer(playerid)
{
	HidePlayerProgressBar(playerid, KnockoutBar);

	ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	knockout_Tick[playerid] = tickcount();
	f:bPlayerGameSettings[playerid]<KnockedOut>;
}

KnockOutUpdate(playerid)
{
	if(bPlayerGameSettings[playerid] & Dying)
	{
		f:bPlayerGameSettings[playerid]<KnockedOut>;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		new animidx = GetPlayerAnimationIndex(playerid);
		if(animidx != 1207 && animidx != 1018 && animidx != 1001)
			KnockOutPlayer(playerid, GetPlayerKnockoutDuration(playerid) - (tickcount() - GetPlayerKnockOutTick(playerid)));

		SetPlayerProgressBarValue(playerid, KnockoutBar, tickcount() - GetPlayerKnockOutTick(playerid));
		SetPlayerProgressBarMaxValue(playerid, KnockoutBar, GetPlayerKnockoutDuration(playerid));
		UpdatePlayerProgressBar(playerid, KnockoutBar);

		if(tickcount() - GetPlayerKnockOutTick(playerid) >= GetPlayerKnockoutDuration(playerid))
		{
			WakeUpPlayer(playerid);
		}
	}
	else
	{
		HidePlayerProgressBar(playerid, KnockoutBar);

		if(gPlayerHP[playerid] < 50.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				if(tickcount() - GetPlayerKnockOutTick(playerid) > 5000 * gPlayerHP[playerid])
				{
					if(bPlayerGameSettings[playerid] & Bleeding)
					{
						if(frandom(40.0) < (50.0 - gPlayerHP[playerid]))
							KnockOutPlayer(playerid, floatround(2000 * (50.0 - gPlayerHP[playerid]) + frandom(200 * (50.0 - gPlayerHP[playerid]))));
					}
					else
					{
						if(frandom(40.0) < (40.0 - gPlayerHP[playerid]))
							KnockOutPlayer(playerid, floatround(2000 * (40.0 - gPlayerHP[playerid]) + frandom(200 * (40.0 - gPlayerHP[playerid]))));
					}
				}
			}
		}
	}

	return;
}

GetPlayerKnockOutTick(playerid)
{
	return knockout_Tick[playerid];
}

GetPlayerKnockoutDuration(playerid)
{
	return knockout_Duration[playerid];
}

CMD:knockout(playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	return 1;
}
