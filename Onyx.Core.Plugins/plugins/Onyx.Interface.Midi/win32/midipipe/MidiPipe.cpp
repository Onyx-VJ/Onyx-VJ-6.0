// MidiPipe.cpp : Defines the entry point for the console application.
// Original code from Jason Hotchkiss
//

#include "stdafx.h"
#include <iostream>

HMIDIIN hMidiIn = NULL;
HMIDIOUT hMidiOut = NULL;
#define BUF_SIZE 200
char szBuffer[BUF_SIZE + 1] = {0};
int iBufferIndex = 0;

//////////////////////////////////////////////////////////
//
// MIDI MESSAGE CALLBACK
//
//////////////////////////////////////////////////////////
void CALLBACK MidiInProc(HMIDIIN hMidiIn, UINT wMsg, DWORD dwInstance, DWORD dwParam1, DWORD dwParam2) {

	if(wMsg == MIM_DATA)
	{
		fprintf(stdout, "!%X %X %X\n", dwParam1, dwParam2, hMidiIn);

		//if ( ( dwParam1 & 0x90 ) == 0x90 ) {
		//	fprintf(stdout, "!%d\n",  dwParam1, dwParam2);
		//}			

		//if (((dwParam1 >> 16) & 0xff) != 0 ) {
		//	fprintf(stdout, "!%d\n", dwParam1, dwParam2);
		//}

		/*FILE *fo = fopen("midipipe.txt", "at");
		fprintf(fo, ">!%d,%d,%d\n", 
		(int)dwParam1 & 0xff, 
		(((int)dwParam1) >> 8) & 0xff, 
		(((int)dwParam1) >> 16) & 0xff);
		fclose(fo);*/
	}
}

//////////////////////////////////////////////////////////
//
// STOP MIDI IN
//
//////////////////////////////////////////////////////////
void StopMidiIn()
{
    if(hMidiIn)
    {
        midiInClose(hMidiIn);
        hMidiIn = NULL;
    }
	fprintf(stdout, "--OK\n");
}
//////////////////////////////////////////////////////////
//
// STOP MIDI OUT
//
//////////////////////////////////////////////////////////
void StopMidiOut()
{
    if(hMidiOut)
    {
        midiOutReset(hMidiOut);
        midiOutClose(hMidiOut);
        hMidiOut = NULL;
    }
	fprintf(stdout, "--OK\n");
}
//////////////////////////////////////////////////////////
//
// START MIDI IN
//
//////////////////////////////////////////////////////////
int StartMidiIn(char *szDevice)
{
	int iCount;
	int iDevice;
	UINT uiDevices;
	MMRESULT result;

	// convert device name to lower case
	WCHAR wcsDevice[MAXPNAMELEN + 1];
	for(iCount = 0; szDevice[iCount] && iCount < MAXPNAMELEN; ++iCount)
		wcsDevice[iCount] = tolower(szDevice[iCount]);
	wcsDevice[iCount] = 0;

	// stop midi if already open
	if(hMidiIn)
		StopMidiIn();

	//////////////////////////////////////////////////////////
	// OPEN UP MIDI INPUT DEVICE
    uiDevices = midiInGetNumDevs(); 
    for(iDevice = 0; iDevice < (int)uiDevices; ++iDevice)
    {
        MIDIINCAPS stMIC = {0};
        if(MMSYSERR_NOERROR == midiInGetDevCaps(iDevice, &stMIC, sizeof(stMIC)))
        {
			_wcslwr(stMIC.szPname);
            if(wcsstr(stMIC.szPname, wcsDevice))
            {
				result = midiInOpen(&hMidiIn, iDevice, (DWORD)MidiInProc, NULL, CALLBACK_FUNCTION);
                if(result != MMSYSERR_NOERROR)
                {
					fprintf(stdout, "*** failed to open MIDI input device \'%S\', status=%lx\n", stMIC.szPname, result);
					return 0;
				}
				result = midiInStart(hMidiIn);
                if(result != MMSYSERR_NOERROR)
				{
					fprintf(stdout, "*** failed to start MIDI input device \'%S\', status=%lx\n", stMIC.szPname, result);
					return 0;
				}
				fprintf(stdout, "-opened input device \'%S\'\n", stMIC.szPname);
				break;
            }
        }
    }
	fprintf(stdout, "--OK");
	return 1;
} 
//////////////////////////////////////////////////////////
//
// START MIDI OUT
//
//////////////////////////////////////////////////////////
int StartMidiOut(char *szDevice)
{
	int iCount;
	int iDevice;
	UINT uiDevices;
	MMRESULT result;

	// convert device name to lower case
	WCHAR wcsDevice[MAXPNAMELEN + 1];
	for(iCount = 0; szDevice[iCount] && iCount < MAXPNAMELEN; ++iCount)
		wcsDevice[iCount] = tolower(szDevice[iCount]);
	wcsDevice[iCount] = 0;

	// stop midi if already open
	if(hMidiOut)
		StopMidiOut();

	// OPEN UP MIDI OUTPUT DEVICE
    uiDevices = midiOutGetNumDevs(); 
    for(iDevice = 0; iDevice < (int)uiDevices; ++iDevice)
    {
        MIDIOUTCAPS stMOC = {0};
        if(MMSYSERR_NOERROR == midiOutGetDevCaps(iDevice, &stMOC, sizeof(stMOC)))
        {
			_wcslwr(stMOC.szPname);
            if(wcsstr(stMOC.szPname, wcsDevice))
            {
				result = midiOutOpen(&hMidiOut, iDevice, NULL, NULL, 0);
                if(result != MMSYSERR_NOERROR)
                {
					fprintf(stdout, "*** failed to open MIDI output device \'%S\', status=%lx\n", stMOC.szPname, result);
					return 0;
                }
				fprintf(stdout, "- opened output device \'%S\'\n", stMOC.szPname);
				break;
            }
        }
    }

	fprintf(stdout, "--OK");
	return 1;
} 
//////////////////////////////////////////////////////////
//
// SEND CHANNEL MESSAGE
//
//////////////////////////////////////////////////////////
int sendChannelMessage(char *szBuffer)
{
	char *pchPos = szBuffer;
	MMRESULT result;
	int iStatus = 0;
	int iParam1 = 0;
	int iParam2 = 0;

	if(!hMidiOut)
	{
		fprintf(stdout, "*** must open MIDI device before sending channel message\n");
		return 0;
	}

	char *pchEndPtr = NULL;
	iStatus = strtol(pchPos, &pchEndPtr, 10);
	if(!pchEndPtr || *pchEndPtr != ',')
	{
		fprintf(stdout, "*** invalid channel message \'%s\', param 1\n", szBuffer);
		return 0;
	}
	pchPos = pchEndPtr + 1;
	iParam1 = strtol(pchPos, &pchEndPtr, 10);
	if(!pchEndPtr || *pchEndPtr != ',')
	{
		fprintf(stdout, "*** invalid channel message \'%s\', param 2\n", szBuffer);
		return 0;
	}
	pchPos = pchEndPtr + 1;
	iParam2 = strtol(pchPos, &pchEndPtr, 10);
	if(pchEndPtr && *pchEndPtr != '\0')
	{
		fprintf(stdout, "*** invalid channel message %s, param 3\n", szBuffer);
		return 0;
	}

	if(iStatus < 0 || iStatus > 255)
	{
		fprintf(stdout, "*** invalid channel message %s, param 1 out of range\n", szBuffer);
		return 0;
	}
	if(iParam1 < 0 || iParam1 > 127)
	{
		fprintf(stdout, "*** invalid channel message %s, param 2 out of range\n", szBuffer);
		return 0;
	}
	if(iParam2 < 0 || iParam2 > 127)
	{
		fprintf(stdout, "*** invalid channel message %s, param 2 out of range\n", szBuffer);
		return 0;
	}

	DWORD dwMsg = iStatus | (iParam1 << 8) | (iParam2 << 16);
	result = midiOutShortMsg(hMidiOut, dwMsg);
    if(MMSYSERR_NOERROR != result)
	{
		fprintf(stdout, "*** channel send failed, status=%lx\n", result);
		return 0;
    }
	
	//fflush(stdout);

	return 1;
}

//////////////////////////////////////////////////////////
//
// LIST INSTALLED MIDI DEVICES
//
//////////////////////////////////////////////////////////
void ListMidiDevices()
{
	UINT uiDevices;
	int iDevice;
    uiDevices = midiInGetNumDevs(); 
    for(iDevice = 0; iDevice < (int)uiDevices; ++iDevice)
    {
        MIDIINCAPS stMIC = {0};
        if(MMSYSERR_NOERROR == midiInGetDevCaps(iDevice, &stMIC, sizeof(stMIC)))
			fprintf(stdout, "--IN:%S\n", stMIC.szPname);
    }
    uiDevices = midiOutGetNumDevs(); 
    for(iDevice = 0; iDevice < (int)uiDevices; ++iDevice)
    {
        MIDIOUTCAPS stMOC = {0};
        if(MMSYSERR_NOERROR == midiOutGetDevCaps(iDevice, &stMOC, sizeof(stMOC)))
			fprintf(stdout, "--OT:%S\n", stMOC.szPname);
    }

	fprintf(stdout, "--OK\n");
	fflush(stdout);

}

//////////////////////////////////////////////////////////
//
// COMMAND HANDLER
//
//////////////////////////////////////////////////////////
int handleMessage(char *szBuffer)
{
	/* FILE *fo = fopen("midipipe.txt", "at");
	fprintf(fo, "<%s\n", szBuffer);
	fclose(fo);
	*/

	_strlwr(szBuffer);
	if(isdigit(szBuffer[0]))
	{
		return sendChannelMessage(szBuffer);
	}
	else if(strncmp(szBuffer, "inpt ", 5) == 0)
	{
		return StartMidiIn(&szBuffer[5]);
	}
	else if(strncmp(szBuffer, "outp ", 5) == 0)
	{
		return StartMidiOut(&szBuffer[5]);
	}
	else if(strcmp(szBuffer, "close") == 0)
	{
		StopMidiIn();
		StopMidiOut();
		return 1;
	}
	else if(strcmp(szBuffer, "list") == 0)
	{
		ListMidiDevices();
		return 1;
	}
	else if(strcmp(szBuffer, "quit") == 0)
	{
		return -1;
	}
	else
	{
		fprintf(stdout, "*** unrecognised command\n");
		return 0;
	}
}

//////////////////////////////////////////////////////////
//
// SHUTDOWN HANDLER
//
//////////////////////////////////////////////////////////
void terminalHandler( int sig ) 
{
	StopMidiIn();
	StopMidiOut();
    fclose( stdout );
    exit(1);
}
 

//////////////////////////////////////////////////////////
//
// SHUTDOWN HANDLER
//
//////////////////////////////////////////////////////////
int main(int argc, char** argv)
{
    _setmode( _fileno( stdin ), _O_BINARY );
    _setmode( _fileno( stdout ), _O_BINARY );
	setvbuf( stdout, NULL, _IONBF, 0 );

    signal( SIGABRT, terminalHandler );
    signal( SIGTERM, terminalHandler );
    signal( SIGINT, terminalHandler );

    // close the pipe to exit the app
    while ( !feof( stdin ) )
    {
		// poll for 
		char ch;
		int iCharsRead = fread( &ch, 1, 1, stdin);
        if( ferror( stdin ))
        {
           perror("*** read from stdin failed");
           exit(1);
        }
		else if(iBufferIndex >= BUF_SIZE-1)
		{
           perror("*** input buffer overflow");
           exit(2);
		}
		else if(ch == '\n')
		{
			szBuffer[iBufferIndex] = '\0';
			if(handleMessage(szBuffer)<0)
				break;
			iBufferIndex = 0;
		}
		else if(ch != '\r')
		{
			szBuffer[iBufferIndex++] = ch;
		}
	}
    return 0;
}