new
	ammo_ContainerOption[MAX_PLAYERS];


public OnItemCreated(itemid)
{
	if(GetItemType(itemid) == item_AmmoTin)
	{
		defer ConvertOldAmmoTin(itemid);
		return 1;
	}

	if(GetItemType(itemid) == item_Ammo9mm)
		SetItemExtraData(itemid, random(14));

	if(GetItemType(itemid) == item_AmmoBuck)
		SetItemExtraData(itemid, random(7));

	if(GetItemType(itemid) == item_Ammo556)
		SetItemExtraData(itemid, random(35));

	if(GetItemType(itemid) == item_Ammo357)
		SetItemExtraData(itemid, random(4));

	if(GetItemType(itemid) == item_AmmoRocket)
		SetItemExtraData(itemid, random(1));

	return CallLocalFunction("ammo_OnItemCreated", "d", itemid);
}
#if defined _ALS_OnItemCreated
	#undef OnItemCreated
#else
	#define _ALS_OnItemCreated
#endif
#define OnItemCreated ammo_OnItemCreated
forward ammo_OnItemCreated(itemid);

timer ConvertOldAmmoTin[5](itemid)
{
	new
		type = (GetItemExtraData(itemid) >> 8) & 0xFF,
		amount = GetItemExtraData(itemid) & 0xFF,
		ItemType:itemtype;

	if(!(0 < type <= AMMO_TYPE_ROCKET))
	{
		DestroyItem(itemid);
	}

	switch(type)
	{
		case AMMO_TYPE_9MM:
			itemtype = item_Ammo9mm;

		case AMMO_TYPE_BUCK:
			itemtype = item_AmmoBuck;

		case AMMO_TYPE_556:
			itemtype = item_Ammo556;

		case AMMO_TYPE_357:
			itemtype = item_Ammo357;

		case AMMO_TYPE_ROCKET:
			itemtype = item_AmmoRocket;
	}

	if(itemtype > ItemType:0)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);

		DestroyItem(itemid);
		itemid = CreateItem(itemtype, x, y, z, rx, ry, rz, .zoffset = FLOOR_OFFSET);
		SetItemExtraData(itemid, amount);
	}
}

stock IsItemTypeAmmoTin(ItemType:itemtype)
{
	if(itemtype == item_Ammo9mm)
		return 1;

	if(itemtype == item_Ammo50)
		return 1;

	if(itemtype == item_AmmoBuck)
		return 1;

	if(itemtype == item_Ammo556)
		return 1;

	if(itemtype == item_Ammo357)
		return 1;

	if(itemtype == item_AmmoRocket)
		return 1;

	return 0;
}

stock GetAmmoTinAmmoType(ItemType:itemtype)
{
	if(itemtype == item_Ammo9mm)
		return AMMO_TYPE_9MM;

	if(itemtype == item_AmmoBuck)
		return AMMO_TYPE_BUCK;

	if(itemtype == item_Ammo556)
		return AMMO_TYPE_556;

	if(itemtype == item_Ammo357)
		return AMMO_TYPE_357;

	if(itemtype == item_AmmoRocket)
		return AMMO_TYPE_ROCKET;

	return AMMO_TYPE_NONE;
}

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new selecteditemtype = _:GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid)));

	if(IsWeaponClipBased(selecteditemtype) || IsItemTypeAmmoTin(ItemType:selecteditemtype))
	{
		new
			helditemtype = _:GetItemType(GetPlayerItem(playerid)),
			selectedammotype,
			heldammotype;

		helditemtype = _:GetItemType(GetPlayerItem(playerid));

		if(IsItemTypeAmmoTin(ItemType:helditemtype))
		{
			heldammotype = GetAmmoTinAmmoType(ItemType:helditemtype);
		}
		else
		{
			if(IsWeaponClipBased(helditemtype))
			{
				heldammotype = GetWeaponAmmoType(helditemtype);
			}
			else
			{
				helditemtype = GetPlayerCurrentWeapon(playerid);

				if(IsWeaponClipBased(helditemtype))
				{
					heldammotype = GetWeaponAmmoType(helditemtype);
				}
			}
		}

		if(IsItemTypeAmmoTin(ItemType:selecteditemtype))
		{
			selectedammotype = GetAmmoTinAmmoType(ItemType:selecteditemtype);
		}
		else
		{
			if(IsWeaponClipBased(selecteditemtype))
			{
				selectedammotype = GetWeaponAmmoType(selecteditemtype);
			}
		}

		if(AMMO_TYPE_NONE < selectedammotype <= AMMO_TYPE_ROCKET && AMMO_TYPE_NONE < heldammotype <= AMMO_TYPE_ROCKET)
		{
			if(selecteditemtype == _:GetWeaponAmmoTypeItem(helditemtype))
				ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer ammo from tin to gun");			// TIN TO GUN

			else if(helditemtype == selecteditemtype)
				ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo from tin to ammo tin");	// TIN TO TIN

			else if(_:GetWeaponAmmoTypeItem(selecteditemtype) == helditemtype)
				ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo from gun to ammo tin");	// GUN TO TIN

			else if(GetWeaponAmmoType(selecteditemtype) == GetWeaponAmmoType(helditemtype))
				ammo_ContainerOption[playerid] = AddContainerOption(playerid, "Transfer Ammo from gun to gun");			// GUN TO GUN
		}
	}


	return CallLocalFunction("ammo_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt ammo_OnPlayerViewContainerOpt
forward ammo_OnPlayerViewContainerOpt(playerid, containerid);


public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new selecteditemtype = _:GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid)));

	if(IsWeaponClipBased(selecteditemtype) || IsItemTypeAmmoTin(ItemType:selecteditemtype))
	{
		new
			helditemtype = _:GetItemType(GetPlayerItem(playerid)),
			selectedammotype,
			heldammotype;

		helditemtype = _:GetItemType(GetPlayerItem(playerid));

		if(IsItemTypeAmmoTin(ItemType:helditemtype))
		{
			heldammotype = GetAmmoTinAmmoType(ItemType:helditemtype);
		}
		else
		{
			if(IsWeaponClipBased(helditemtype))
			{
				heldammotype = GetWeaponAmmoType(helditemtype);
			}
			else
			{
				helditemtype = GetPlayerCurrentWeapon(playerid);

				if(IsWeaponClipBased(helditemtype))
				{
					heldammotype = GetWeaponAmmoType(helditemtype);
				}
			}
		}

		if(IsItemTypeAmmoTin(ItemType:selecteditemtype))
		{
			selectedammotype = GetAmmoTinAmmoType(ItemType:selecteditemtype);
		}
		else
		{
			if(IsWeaponClipBased(selecteditemtype))
			{
				selectedammotype = GetWeaponAmmoType(selecteditemtype);
			}
		}

		if(AMMO_TYPE_NONE < selectedammotype <= AMMO_TYPE_ROCKET && AMMO_TYPE_NONE < heldammotype <= AMMO_TYPE_ROCKET)
		{
			if(selecteditemtype == _:GetWeaponAmmoTypeItem(helditemtype))
				ShowPlayerDialog(playerid, d_TransferAmmoToGun, DIALOG_STYLE_INPUT, "Transfer Ammo from tin to gun", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(helditemtype == selecteditemtype)
				ShowPlayerDialog(playerid, d_TransferAmmoToBox, DIALOG_STYLE_INPUT, "Transfer Ammo from tin to ammo tin", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(_:GetWeaponAmmoTypeItem(selecteditemtype) == helditemtype)
				ShowPlayerDialog(playerid, d_TransferAmmoToBox, DIALOG_STYLE_INPUT, "Transfer Ammo from gun to ammo tin", "Enter the amount of ammo to transfer", "Accept", "Cancel");

			else if(GetWeaponAmmoType(selecteditemtype) == GetWeaponAmmoType(helditemtype))
				ShowPlayerDialog(playerid, d_TransferAmmoToGun, DIALOG_STYLE_INPUT, "Transfer Ammo from gun to gun", "Enter the amount of ammo to transfer", "Accept", "Cancel");
		}
	}

	return CallLocalFunction("ammo_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt ammo_OnPlayerSelectContainerOpt
forward ammo_OnPlayerSelectContainerOpt(playerid, containerid, option);

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_TransferAmmoToGun)
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		if(response)
		{
			new amount = strval(inputtext);

			if(amount > 0)
			{
				new
					slot,
					itemid,
					weaponid,
					remainder;

				slot = GetPlayerContainerSlot(playerid);
				itemid = GetContainerSlotItem(containerid, slot);
				weaponid = GetPlayerCurrentWeapon(playerid);

				if(amount > GetItemExtraData(itemid))
				{
					DisplayContainerInventory(playerid, containerid);
					return 1;
				}

				if(weaponid > 0)
				{
					if(GetWeaponAmmoTypeItem(weaponid) != GetItemType(itemid) && GetWeaponAmmoType(_:GetItemType(itemid)) != GetWeaponAmmoType(weaponid))
					{
						DisplayContainerInventory(playerid, containerid);
						return 1;
					}

					remainder = GivePlayerAmmo(playerid, amount);
					SetItemExtraData(itemid, remainder + GetItemExtraData(itemid) - amount);
				}
				else
				{
					weaponid = _:GetItemType(GetPlayerItem(playerid));

					if(GetWeaponAmmoTypeItem(weaponid) != GetItemType(itemid) && GetWeaponAmmoType(_:GetItemType(itemid)) != GetWeaponAmmoType(weaponid))
					{
						DisplayContainerInventory(playerid, containerid);
						return 1;
					}

					if(IsWeaponClipBased(weaponid))
					{
						remainder = GetAmmunitionRemainder(weaponid, 0, amount);
						SetItemExtraData(GetPlayerItem(playerid), amount - remainder);
						ConvertPlayerItemToWeapon(playerid);
						SetItemExtraData(itemid, remainder + GetItemExtraData(itemid) - amount);
					}
				}
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}
	if(dialogid == d_TransferAmmoToBox)
	{
		new containerid = GetPlayerCurrentContainer(playerid);

		if(response)
		{
			new amount = strval(inputtext);

			if(amount > 0)
			{
				new
					slot,
					selecteditemid,
					total,
					helditemid;

				slot = GetPlayerContainerSlot(playerid);
				selecteditemid = GetContainerSlotItem(containerid, slot);
				total = GetItemExtraData(selecteditemid);

				if(amount > total)
				{
					DisplayContainerInventory(playerid, containerid);
					return 1;
				}

				helditemid = GetPlayerItem(playerid);

				if(GetItemType(helditemid) == GetWeaponAmmoTypeItem(_:GetItemType(selecteditemid)) ||
					GetWeaponAmmoType(_:GetItemType(helditemid)) == GetWeaponAmmoType(_:GetItemType(selecteditemid)) ||
					GetItemType(helditemid) == GetItemType(selecteditemid))
				{
					SetItemExtraData(helditemid, GetItemExtraData(helditemid) + amount);
					SetItemExtraData(selecteditemid, total - amount);
				}
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	return 1;
}

public OnItemNameRender(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Ammo9mm || itemtype == item_Ammo50 || itemtype == item_AmmoBuck ||
		itemtype == item_Ammo556 || itemtype == item_Ammo357 || itemtype == item_AmmoRocket)
	{
		new
			amount = GetItemExtraData(itemid),
			str[11];

		if(amount <= 0)
		{
			str = "Empty";
		}
		else
		{
			valstr(str, amount);
		}

		SetItemNameExtra(itemid, str);
	}

	return CallLocalFunction("ammo_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender ammo_OnItemNameRender
forward ammo_OnItemNameRender(itemid);
