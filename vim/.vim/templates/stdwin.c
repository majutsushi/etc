#define _WIN32_WINNT 0x0501
#include <Windows.h>

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg,
                         WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_PAINT:
    {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hWnd, &ps);

        TextOut(hdc, 10, 10, TEXT("Hello World!"), -1);

        EndPaint(hWnd, &ps);
        return 0;
    }
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    }
    return DefWindowProc(hWnd, uMsg, wParam, lParam);
}

int CALLBACK WinMain(HINSTANCE hInst, HINSTANCE hPreInst,
                     LPSTR strCmdLine, int nCmdShow)
{
    MSG msg;
    HWND hWnd;
    WNDCLASSEX wc =
    {
        sizeof(wc), CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS,
        WndProc, 0, 0, hInst,
        LoadIcon(NULL, IDI_APPLICATION), LoadCursor(NULL, IDC_ARROW),
        (HBRUSH)GetStockObject(WHITE_BRUSH), NULL, "My Class", NULL
    };

    hWnd = CreateWindowEx(0,
                          MAKEINTRESOURCE(RegisterClassEx(&wc)),
                          "My Window", WS_OVERLAPPEDWINDOW,
                          CW_USEDEFAULT, CW_USEDEFAULT, 320, 240,
                          NULL, NULL, hInst, NULL);
    if (!IsWindow(hWnd))
        return 1;
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    return msg.wParam;
}

/* cc: flags+='-mwindows -static': */
