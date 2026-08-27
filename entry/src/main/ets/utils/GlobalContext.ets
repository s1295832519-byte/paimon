export class GlobalContext {
  private static instance: GlobalContext;
  private _objects = new Map<string, Object>();

  private constructor() {
  }

  public static getInstance(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getContext(value: string): Object | undefined {
    return this._objects.get(value);
  }

  setContext(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }
}