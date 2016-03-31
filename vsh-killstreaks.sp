#pragma semicolon 1
 
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <saxtonhale>
 
#define PLUGIN_NAME "[VSH] Killstreak Calculator"
#define PLUGIN_AUTHOR "Aurora"
#define PLUGIN_DESCRIPTION "Calculates the amount of Killstreaks to give a player based on damage."
#define PLUGIN_VERSION "1.1"
#define PLUGIN_URL "http://tajdeluca.com"
 
public Plugin:myinfo =
{
        name = PLUGIN_NAME,
        author = PLUGIN_AUTHOR,
        description = PLUGIN_DESCRIPTION,
        version = PLUGIN_VERSION,
        url = PLUGIN_URL
}
 
#define PERCENTAGE_REQUIRED 0.02
 
new bool:g_iLate = false;
 
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
        g_iLate = true;
        return APLRes_Success;
}
 
public OnPluginStart()
{
        if(g_iLate)
        {
                for(new i=1; i<=MaxClients; i++)
                {
                        if(IsValidClient(i))
                                SDKHook(i, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
                }
        }
}
 
public OnClientPutInServer(client)
{
        SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}
 
public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype)
{
        if(!VSH_IsSaxtonHaleModeEnabled())
        {
                return;
        }
       
        if(IsValidClient(attacker) && GetClientUserId(victim) == VSH_GetSaxtonHaleUserId())
        {
                new maxHealth = VSH_GetSaxtonHaleHealthMax();
                new damageDealt = VSH_GetClientDamage(attacker);
 
                new Float:dmgRequired = float(maxHealth) * PERCENTAGE_REQUIRED;
                new killStreak = damageDealt / RoundToCeil(dmgRequired);
 
                SetEntProp(attacker, Prop_Send, "m_nStreaks", killStreak);
        }
}
 
// Stocks
 
stock bool:IsValidClient(client, bool:replaycheck = true)
{
        if (client <= 0 || client > MaxClients) return false;
        if (!IsClientInGame(client)) return false;
        if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
        if (replaycheck)
        {
                if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
        }
        return true;
}